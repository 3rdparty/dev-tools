#!/bin/bash
#
# Measures the flakiness (the percentage of failures) of the given command.
#
# Usage: measure_flakiness.sh $COMMAND_TO_RUN

RUN_COUNT=10
echo "Running the following command ${RUN_COUNT} times to measure flakiness: ${@}"
 
failure_count=0
for (( i=0; i<$RUN_COUNT; i++ ))
do
    if ! ${@};
    then
        failure_count=$((failure_count + 1))
    fi
done

success_count=$((RUN_COUNT - failure_count))
# Round up when dividing so 0.1% flaky is reported as 1%, not 0%. See
# https://stackoverflow.com/a/2395294
flaky_percentage=$(((failure_count * 100 + RUN_COUNT - 1) / RUN_COUNT))
echo "${success_count}/${RUN_COUNT} runs succeeded (${flaky_percentage}% flaky)"
