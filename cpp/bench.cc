#include <iostream>
#include "badmath.hh"
#include "prcoords.h"
#define ANKERL_NANOBENCH_IMPLEMENT
#include "nanobench.h"

double uniform(ankerl::nanobench::Rng& rng, double a, double b){
    return rng.uniform01() * (b - a) + a;
}

PRCoords rand_coord(ankerl::nanobench::Rng& rng){
    return PRCoords{.lat = uniform(rng, -90, 90), .lon = uniform(rng, -180, 180)};
}

int main(){
    using namespace badmath;
    auto rng = ankerl::nanobench::Rng();
    ankerl::nanobench::Bench().minEpochIterations(10000).run(
        "nop", [&]() {
            auto coord = rand_coord(rng);
            ankerl::nanobench::doNotOptimizeAway(coord);
        }
    );
    ankerl::nanobench::Bench().minEpochIterations(10000).run(
        "wgs_gcj", [&]() {
            auto coord = rand_coord(rng);
            auto res = prcoords_wgs_gcj(coord);
            ankerl::nanobench::doNotOptimizeAway(res);
        }
    );
    ankerl::nanobench::Bench().minEpochIterations(10000).run(
        "gcj_wgs", [&]() {
            auto coord = rand_coord(rng);
            auto res = prcoords_gcj_wgs(coord);
            ankerl::nanobench::doNotOptimizeAway(res);
        }
    );
    ankerl::nanobench::Bench().minEpochIterations(10000).run(
        "gcj_wgs_bored", [&]() {
            auto coord = rand_coord(rng);
            auto res = prcoords_gcj_wgs_bored(coord);
            ankerl::nanobench::doNotOptimizeAway(res);
        }
    );
    ankerl::nanobench::Bench().minEpochIterations(10000).run(
        "bd_wgs_bored", [&]() {
            auto coord = rand_coord(rng);
            auto res = prcoords_gcj_wgs_bored(coord);
            ankerl::nanobench::doNotOptimizeAway(res);
        }
    );
    ankerl::nanobench::Bench().minEpochIterations(10000).run(
        "gcj_bd", [&]() {
            auto coord = rand_coord(rng);
            auto res = prcoords_gcj_bd(coord);
            ankerl::nanobench::doNotOptimizeAway(res);
        }
    );
    return 0;
}
