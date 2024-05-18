#!/bin/sh

bench_to_file() {
    make clean
    make bench XCXXFLAGS="$1"
    ./bench > bench_out/$2.md
}

native='-march=native'
stdsin='-DPRCOORDS_NO_BADMATH'

if (( ! KEEP_GOVNOR )); then
    OL_GOVNOR=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
    echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
fi


bench_to_file "$native" 'native_nick'
bench_to_file "$native $stdsin" 'native_stdsin'
bench_to_file "" 'nick'
bench_to_file "$stdsin" 'stdsin'

if [[ -n $OL_GOVNOR ]]; then
    echo $OL_GOVNOR | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
fi
