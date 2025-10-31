#!/bin/bash
# =======================
# test_cpreq.sh
# -------------
# Purpose: test ush/cpreq
#
# Arguments: None
# =======================

# -----------------
# Utility functions
# -----------------

setup() {
    test_dir=$1
    source_dir=${test_dir}/source_dir
    target_dir=${test_dir}/target_dir
    mkdir -p ${source_dir}
    mkdir -p ${target_dir}
}

teardown() {
    echo "${FUNCNAME} not implemented"
    #cd ${TMP_DIR}
    #rm -rf ${TMP_DIR}/*
    #cd ${TMP_DIR}/..
    #rmdir ${TMP_DIR}
}

wrapper() {
    func=$1
    echo "----------------------------"

    ${func}

    echo "----------------------------"
    echo ""
}

check_results() {
    func_name=$1
    err=$2
    err_msg=$3

    if [[ $err -eq 0 ]]; then
        echo "PASSED: ${func_name}"
        export NPASSED=$(( NPASSED + 1 ))
    else
        echo "FAILED: ${func_name}"
        echo "$err_msg"
        export NFAILED=$(( NFAILED + 1))
    fi
}

err_chk() {
    /lfs/h1/nco/idsb/noscrub/russell.manser/git_repos/prod_util/tests/patch/err_chk "$*"
}

err_exit() {
    /lfs/h1/nco/idsb/noscrub/russell.manser/git_repos/prod_util/tests/patch/err_exit
}

# ----------
# Test suite
# ----------


test_one_file() {
    # Test that cpreq copies a single nonzero size file
    # -------------------------------------------------
    test_dir=${TMP_DIR}/${FUNCNAME}
    setup "${test_dir}"

    export pgm=${FUNCNAME}

    echo "This is a file with text in it" > ${test_dir}/source_dir/file.txt

    $TARGET_SCRIPT ${test_dir}/source_dir/file.txt ${test_dir}/target_dir/ 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err

    err_msg=$( grep "FATAL ERROR" ${test_dir}/${FUNCNAME}.err )

    test -z "$err_msg"
    check_results ${FUNCNAME} $? "$err_msg"
}


test_one_empty_file_no_flag() {
    # -------------------------------------------------------
    # Test that cpreq *fails* to copy a single zero size file
    # without the specified '-z' option
    #
    # This test will pass upon *any* failure.
    #
    # TODO: pass only on specific failure.
    # -------------------------------------------------------
    test_dir=${TMP_DIR}/${FUNCNAME}
    setup "${test_dir}"

    export pgm=${FUNCNAME}

    touch ${test_dir}/source_dir/file.txt
    $TARGET_SCRIPT ${test_dir}/source_dir/file.txt ${test_dir}/target_dir 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err

    err_msg=$( grep "FATAL ERROR" ${test_dir}/${FUNCNAME}.err )

    test ! -z "$err_msg"
    check_results ${FUNCNAME} $? "$err_msg"
}


test_one_empty_file_flag() {
    # ------------------------------------------------------
    # Test that cpreq copys a single zero size file with the
    # '-z' option specified
    # ------------------------------------------------------
    test_dir=${TMP_DIR}/${FUNCNAME}
    setup "${test_dir}"

    export pgm=${FUNCNAME}

    touch ${test_dir}/source_dir/file.txt
    $TARGET_SCRIPT -z ${test_dir}/source_dir/file.txt ${test_dir}/target_dir 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err

    err_msg=$( grep "FATAL ERROR" ${test_dir}/${FUNCNAME}.err )

    test -z "$err_msg"
    check_results ${FUNCNAME} $? "$err_msg"
}


test_multiple_files() {
    # --------------------------------------------------
    # Test that cpreq copies multiple nonzero size files
    # --------------------------------------------------
    test_dir=${TMP_DIR}/${FUNCNAME}
    setup "${test_dir}"

    export pgm=${FUNCNAME}

    for i in $( seq 1 3 ); do
        echo "This is file $i with text in it" > ${test_dir}/source_dir/file${i}.txt
    done

    $TARGET_SCRIPT ${test_dir}/source_dir/file* ${test_dir}/target_dir 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err

    err_msg=$( grep "FATAL ERROR" ${test_dir}/${FUNCNAME}.err )

    test -z "$err_msg"
    check_results ${FUNCNAME} $? "$err_msg"
}


test_multiple_empty_files_no_flag() {
    # -----------------------------------------------------
    # Test that cpreq *fails* to copy multiple files if one
    # or more are size zero and the '-z' is not specified
    #
    # This test will pass upon *any* failure.
    #
    # TODO: pass only on specific failure.
    # -----------------------------------------------------
    test_dir=${TMP_DIR}/${FUNCNAME}
    setup "${test_dir}"

    export pgm=${FUNCNAME}

    for i in $( seq 1 3 ); do
        touch ${test_dir}/source_dir/file${i}.txt
    done

    $TARGET_SCRIPT ${test_dir}/source_dir/file* ${test_dir}/target_dir 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err

    err_msg=$( grep "FATAL ERROR" ${test_dir}/${FUNCNAME}.err )

    test ! -z "$err_msg"
    check_results ${FUNCNAME} $? "$err_msg"
}


test_multiple_empty_files_flag() {
    # ---------------------------------------------------
    # Test the cpreq copies multiple zero size files with
    # the '-z' option specified
    # ---------------------------------------------------
    test_dir=${TMP_DIR}/${FUNCNAME}
    setup "${test_dir}"

    export pgm=${FUNCNAME}

    for i in $( seq 1 3 ); do
        touch ${test_dir}/source_dir/file${i}.txt
    done

    $TARGET_SCRIPT -z ${test_dir}/source_dir/file* ${test_dir}/target_dir 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err

    err_msg=$( grep "FATAL ERROR" ${test_dir}/${FUNCNAME}.err )

    test -z "$err_msg"
    check_results ${FUNCNAME} $? "$err_msg"
}


test_mixed_files_no_flag() {
    # ---------------------------------------------------
    # Test that cpreq *fails* to copy multiple files when
    # one or more are size zero and '-z' is not specified
    #
    # This test will pass upon *any* failure.
    #
    # TODO: pass only on specific failure.
    # ---------------------------------------------------
    test_dir=${TMP_DIR}/${FUNCNAME}
    setup "${test_dir}"

    export pgm=${FUNCNAME}

    echo "This is a file with text in it" > ${test_dir}/source_dir/file1.txt
    touch ${test_dir}/source_dir/file2.txt

    $TARGET_SCRIPT ${test_dir}/source_dir/file* ${test_dir}/target_dir 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err

    err_msg=$( grep "FATAL ERROR" ${test_dir}/${FUNCNAME}.err )

    test ! -z "$err_msg"
    check_results ${FUNCNAME} $? "$err_msg"
}


test_mixed_files_flag() {
    # -------------------------------------------------
    # Test that cpreq copies multiple files when one or
    # more are size zero and '-z' is specified
    # -------------------------------------------------
    test_dir=${TMP_DIR}/${FUNCNAME}
    setup "${test_dir}"

    export pgm=${FUNCNAME}

    echo "This is a file with text in it" > ${test_dir}/source_dir/file1.txt
    touch ${test_dir}/source_dir/file2.txt

    $TARGET_SCRIPT -z ${test_dir}/source_dir/file* ${test_dir}/target_dir 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err
    
    err_msg=$( grep "FATAL ERROR" ${test_dir}/${FUNCNAME}.err )

    test -z "$err_msg"
    check_results ${FUNCNAME} $? "$err_msg"
}


test_with_cp_flags() {
    # ------------------------------------
    # Test that cpreq accepts cp arguments
    # ------------------------------------
    test_dir=${TMP_DIR}/${FUNCNAME}
    setup "${test_dir}"

    export pgm=${FUNCNAME}

    echo "This is a file with text in it" > ${test_dir}/source_dir/file1.txt
    
    $TARGET_SCRIPT -z -pi ${test_dir}/source_dir/file* ${test_dir}/target_dir 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err

    err_msg=$( egrep "FATAL ERROR|illegal" ${test_dir}/${FUNCNAME}.err )

    test -z "$err_msg"
    check_results ${FUNCNAME} $? "$err_msg"
}

test_with_cp_target_dir() {
    # -----------------
    # Test with -t flag
    # -----------------
    test_dir=${TMP_DIR}/${FUNCNAME}
    setup "${test_dir}"

    export pgm=${FUNCNAME}

    echo "This is a file with text in it" > ${test_dir}/source_dir/file1.txt

    $TARGET_SCRIPT -t ${test_dir}/target_dir ${test_dir}/source_dir/file1.txt 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err

    err_msg=$( grep "FATAL ERROR" ${test_dir}/${FUNCNAME}.err )

    test -z "$err_msg"
    check_results ${FUNCNAME} $? "$err_msg"
}

test_with_cp_no_target_dir() {
    check_results ${FUNCNAME} 1 "Test not implemented"
}

# -----------
# Main script
# -----------

main() {
    export -f err_chk
    export -f err_exit

    TMP_ROOT="/lfs/h1/nco/stmp/russell.manser"
    export TMP_DIR="${TMP_ROOT}/test_cpreq_$(date +%Y%m%d_%H%M_%N)"
    echo "Test directory: ${TMP_DIR}"

    PKG_ROOT="/lfs/h1/nco/idsb/noscrub/russell.manser/git_repos/prod_util"
    export TARGET_SCRIPT=${PKG_ROOT}/ush/cpreq

    export NPASSED=0
    export NFAILED=0

    echo "$( basename "$0" )"
    echo "====================================="
    wrapper "test_one_file"
    wrapper "test_one_empty_file_no_flag"
    wrapper "test_one_empty_file_flag"
    wrapper "test_multiple_files"
    wrapper "test_multiple_empty_files_no_flag"
    wrapper "test_multiple_empty_files_flag"
    wrapper "test_mixed_files_no_flag"
    wrapper "test_mixed_files_flag"
    wrapper "test_with_cp_flags"
    wrapper "test_with_cp_target_dir"
    wrapper "test_with_cp_no_target_dir"
    echo "====================================="

    echo "Summary"
    echo "Passed: ${NPASSED}"
    echo "Failed: ${NFAILED}"
}

main
