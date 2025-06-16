#include "vec.cuh"

#ifdef TEST_WARP_MEMORY_VEC

void warp::memory::vec::tests(test_data &results) {
    std::cout << "\n --------------- Starting ops/warp/memory/vec tests! ---------------\n" << std::endl;
#ifdef TEST_WARP_MEMORY_VEC_GLOBAL_TO_REGISTER
    warp::memory::vec::global_to_register::tests(results);
#endif
#ifdef TEST_WARP_MEMORY_VEC_GLOBAL_TO_SHARED
    warp::memory::vec::global_to_shared::tests(results);
#endif
#ifdef TEST_WARP_MEMORY_VEC_SHARED_TO_REGISTER
    warp::memory::vec::shared_to_register::tests(results);
#endif
}

#endif