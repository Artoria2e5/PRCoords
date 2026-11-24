#!/bin/bash

bench_to_file() {
    make clean
    make bench XCXXFLAGS="$1"
    ./bench > "bench_out/$2.md"
}

cat_with_name() {
	local i;
	for i; do
		echo "## ${i%.md}"
		cat "$i"
		echo
	done
}

native='-march=native'
sins=(std nick d2 d3 d4)

if (( ! KEEP_GOVNOR )); then
    OL_GOVNOR=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
    echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
fi

f=()

for sin in "${sins[@]}"; do
	bench_to_file "$native -DPRCOORDS_SINPI=$sin" "native_$sin"
	f+=("native_$sin.md")
done

for sin in "${sins[@]}"; do
	bench_to_file "-DPRCOORDS_SINPI=$sin" "generic_$sin"
	f+=("generic_$sin.md")
done

cd bench_out || exit 1
cat_with_name "${f[@]}" > OUT.md
rm -f "${f[@]}"

if [[ -n $OL_GOVNOR ]]; then
    echo "$OL_GOVNOR" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
fi
