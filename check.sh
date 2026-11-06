#!/bin/bash

overall_failed=0

# Check every test case even when an earlier one fails.
for number in 1 2 3 4; do
    input_dir="Testcase${number}"
    output_dir="${input_dir}Diff"
    testcase_failed=0
    differences_found=0

    for first_file in "$input_dir"/*.1.txt; do
        [ -f "$first_file" ] || continue

        second_file="${first_file%.1.txt}.2.txt"
        version="${first_file##*/}"
        version="${version%.1.txt}"
        result_file="$output_dir/${version}Diff.txt"

        if cmp -s "$first_file" "$second_file"; then
            # An identical pair must not have a result file.
            if [ -e "$result_file" ]; then
                testcase_failed=1
            fi
        else
            differences_found=1

            # Ignore the timestamp-bearing headers when comparing output.
            if [ ! -f "$result_file" ]; then
                testcase_failed=1
            elif ! cmp -s \
                <(diff -u "$first_file" "$second_file" | tail -n +3) \
                <(tail -n +3 "$result_file"); then
                testcase_failed=1
            fi
        fi
    done

    if [ "$differences_found" -eq 1 ]; then
        [ -d "$output_dir" ] || testcase_failed=1
    else
        [ ! -e "$output_dir" ] || testcase_failed=1
    fi

    if [ "$testcase_failed" -eq 0 ]; then
        echo "Testcase${number}: PASS"
    else
        echo "Testcase${number}: FAIL"
        overall_failed=1
    fi
done

exit "$overall_failed"
