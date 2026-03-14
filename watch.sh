#!/bin/bash

cleanup() {
    kill $ROC_DEV_ID
}
trap cleanup TERM

restart_roc(){
    kill $ROC_DEV_ID
    rm main
    roc build
    ./main &
    ROC_DEV_ID=$!
}
restart_roc

fswatch -r . | grep --line-buffered 'roc$' | while read line ; do
    restart_roc
done

wait $ROC_DEV_ID
