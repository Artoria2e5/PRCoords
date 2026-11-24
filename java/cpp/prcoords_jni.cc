/**
 * JNI bridge: one call per transform, arrays in and back out.
 *
 * Compiled against the C++ core next door; PRCOORDS_NUM stays double here
 * because the Java side passes jdouble.
 */
#include <jni.h>
#include "prcoords.h"
#include "libprcoords.cc"

namespace {

inline static void run(JNIEnv* env, jdoubleArray lat, jdoubleArray lon, jint n,
         PRCoords (*fn)(PRCoords)) {
    jsize len = std::min(env->GetArrayLength(lat), env->GetArrayLength(lon));
    if (n < 0)
        n = 0;
    if (n > len)
        n = len;

    jdouble* la = env->GetDoubleArrayElements(lat, nullptr);
    jdouble* lo = env->GetDoubleArrayElements(lon, nullptr);
    #pragma omp simd
    for (jsize i = 0; i < n; i++) {
        PRCoords p = {(PRCOORDS_NUM) la[i], (PRCOORDS_NUM) lo[i]};
        p = fn(p);
        la[i] = (jdouble) p.lat;
        lo[i] = (jdouble) p.lon;
    }
    env->ReleaseDoubleArrayElements(lat, la, 0);
    env->ReleaseDoubleArrayElements(lon, lo, 0);
}

} // namespace

#define BATCH(NAME, FN)                                                       \
    JNIEXPORT void JNICALL Java_io_github_artoria2e5_prcoords_Natives_##NAME   \
      (JNIEnv* env, jclass, jdoubleArray lat, jdoubleArray lon, jint n) {      \
        run(env, lat, lon, n, FN);                                             \
    }

extern "C" {

BATCH(wgsGcj, prcoords_wgs_gcj)
BATCH(gcjBd, prcoords_gcj_bd)
BATCH(wgsBd, prcoords_wgs_bd)
BATCH(gcjWgsBored, prcoords_gcj_wgs_bored)
BATCH(bdGcjBored, prcoords_bd_gcj_bored)
BATCH(bdWgsBored, prcoords_bd_wgs_bored)

} // extern "C"
