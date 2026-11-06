#!/bin/bash

# Generate fresh diff output for all four test cases.
for number in 1 2 3 4; do
    input_dir="Testcase${number}"
    output_dir="${input_dir}Diff"

    # Removing old output makes repeated runs produce the same result.
    rm -rf -- "$output_dir"

    for first_file in "$input_dir"/*.1.txt; do
        [ -f "$first_file" ] || continue

        second_file="${first_file%.1.txt}.2.txt"
        version="${first_file##*/}"
        version="${version%.1.txt}"

        # Identical pairs do not get an output file or directory.
        if cmp -s "$first_file" "$second_file"; then
            continue
        fi

        mkdir -p "$output_dir"
        diff -u "$first_file" "$second_file" > \
            "$output_dir/${version}Diff.txt"
    done
done

exit 0
