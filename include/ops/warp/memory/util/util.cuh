/**
 * @file
 * @brief General memory utilities not specialized for either tiles or vectors.
 */
#pragma once

#include <hip/hip_runtime.h>
#include <hip/amd_detail/amd_hip_runtime.h>
#include <hip/amd_detail/hip_ldg.h>

namespace kittens {

/* ----------   Shared memory utilities  ---------- */
__device__ inline float2 load_shared_vec(uint32_t lds_off) {
    float2 result;
    asm volatile(
        "ds_read_b64 %0, %1\n"
        "s_waitcnt lgkmcnt(0)\n"
        : "=v"(result)              // Output: store result in float2
        : "v"(lds_off)              // Input: LDS offset to read from
        : "memory"
    );
    return result;
}

__device__ inline void store_shared_vec(uint32_t lds_off, float2 val) {
    asm volatile(
        "ds_write_b64 %0, %1\n"
        :
        : "v"(lds_off), "v"(val)
        : "memory"
    );
}

__device__ inline float2 load_global_vec2(const float2* gptr) {
    float2 v;
    // Use global_load_dwordx2 which is more cache-friendly than flat_load
    asm volatile(
        "global_load_dwordx2 %0, %1, off\n"
        "s_waitcnt vmcnt(0)\n"
        : "=v"(v) 
        : "v"(gptr)
        : "memory"
    );
    return v;   
}

__device__ inline float4 load_global_vec4(const float4* gptr) {
    float4 v;
    // Use global_load_dwordx4 which is more cache-friendly than flat_load
    asm volatile(
        "global_load_dwordx4 %0, %1, off\n"
        "s_waitcnt vmcnt(0)\n"
        : "=v"(v) 
        : "v"(gptr)
        : "memory"
    );
    return v;   
}

__device__ inline float2 load_global_vec2_async(const float2* gptr) {
    float2 v;
    // Use global_load_dwordx2 which is more cache-friendly than flat_load
    asm volatile(
        "global_load_dwordx2 %0, %1, off\n"
        : "=v"(v) 
        : "v"(gptr)
        : "memory"
    );
    return v;   
}

__device__ inline float4 load_global_vec4_async(const float4* gptr) {
    float4 v;
    // Use global_load_dwordx4 which is more cache-friendly than flat_load
    asm volatile(
        "global_load_dwordx4 %0, %1, off\n"
        : "=v"(v) 
        : "v"(gptr)
        : "memory"
    );
    return v;   
}


/* ----------   To prevent generic addressing  ---------- */

template<typename T> struct move {
    __device__ static inline void lds(T& dst, uint32_t src);
    __device__ static inline void sts(uint32_t dst, const T& src);
    __device__ static inline void ldg(T& dst, T* src);
    __device__ static inline void stg(T* dst, const T& src);
};

// meant to be used only with shared tiles and shared vectors
namespace detail {
template<typename T> struct size_info {
    static constexpr uint32_t bytes    = sizeof(std::remove_reference_t<T>);
};
template<ducks::st::all ST> struct size_info<ST> {
    static constexpr uint32_t elements = ST::num_elements;
    static constexpr uint32_t bytes    = ST::num_elements * sizeof(typename ST::dtype);
};
template<ducks::sv::all SV> struct size_info<SV> {
    static constexpr uint32_t elements = SV::length;
    static constexpr uint32_t bytes    = SV::length * sizeof(typename SV::dtype);
};
}
template<typename... Args>                       inline constexpr uint32_t size_bytes             = 0; // base case
template<typename T, typename... Args>           inline constexpr uint32_t size_bytes<T, Args...> = detail::size_info<T>::bytes + size_bytes<Args...>; // recursive case

} // namespace kittens
