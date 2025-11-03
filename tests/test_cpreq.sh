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


test_one_empty_file_no_opt() {
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


test_one_empty_file_opt() {
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


test_multiple_empty_files_no_opt() {
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


test_multiple_empty_files_opt() {
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


test_mixed_files_no_opt() {
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


test_mixed_files_opt() {
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


test_directory_no_opt() {
    # ------------------------------------------------
    # Test that copying a directory with an empty file
    # *fails* without '-z'
    #
    # This test will pass upon *any* failure
    #
    # TODO: pass only on specific failure
    # ------------------------------------------------
    test_dir=${TMP_DIR}/${FUNCNAME}
    setup "${test_dir}"

    export pgm=${FUNCNAME}

    echo "This is a file with text in it" > ${test_dir}/source_dir/file1.txt
    touch ${test_dir}/source_dir/file2.txt

    $TARGET_SCRIPT -r ${test_dir}/source_dir/ ${test_dir}/target_dir 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err

    err_msg=$( grep -E "FATAL ERROR.*2" ${test_dir}/${FUNCNAME}.err )

    test ! -z "$err_msg"
    check_results ${FUNCNAME} $? "$err_msg"
}


test_directory_opt() {
    # --------------------------------------
    # Test copying a directory recursively
    # which contains an empty file with '-z'
    # --------------------------------------
    test_dir=${TMP_DIR}/${FUNCNAME}
    setup "${test_dir}"

    export pgm=${FUNCNAME}

    echo "This is a file with text in it" > ${test_dir}/source_dir/file1.txt
    touch ${test_dir}/source_dir/file2.txt

    $TARGET_SCRIPT -z -r ${test_dir}/source_dir/ ${test_dir}/target_dir 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err

    err_msg=$( grep "FATAL ERROR" ${test_dir}/${FUNCNAME}.err )

    test -z "$err_msg"
    check_results ${FUNCNAME} $? "$err_msg"
}


test_one_cp_opt() {
    # ----------------------------
    # Test with a single cp option
    # ----------------------------
    test_dir=${TMP_DIR}/${FUNCNAME}
    setup "${test_dir}"

    export pgm=${FUNCNAME}

    echo "This is a file with text in it" > ${test_dir}/source_dir/file1.txt

    $TARGET_SCRIPT -p ${test_dir}/source_dir/file1.txt ${test_dir}/target_dir 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err

    err_msg=$( grep "FATAL ERROR" ${test_dir}/${FUNCNAME}.err )

    test -z "$err_msg"
    check_results ${FUNCNAME} $? "$err_msg"
}


test_one_cp_opt_zero_byte() {
    # -----------------------------------
    # Test with -z and a single cp option
    # -----------------------------------
    test_dir=${TMP_DIR}/${FUNCNAME}
    setup "${test_dir}"

    export pgm=${FUNCNAME}

    touch ${test_dir}/source_dir/file1.txt

    $TARGET_SCRIPT -z -p ${test_dir}/source_dir/file1.txt ${test_dir}/target_dir 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err

    err_msg=$( grep "FATAL ERROR" ${test_dir}/${FUNCNAME}.err )

    test -z "$err_msg"
    check_results ${FUNCNAME} $? "$err_msg"
}


test_multiple_cp_opts() {
    # ---------------------------------------------
    # Test that cpreq accepts multiple cp arguments
    # ---------------------------------------------
    test_dir=${TMP_DIR}/${FUNCNAME}
    setup "${test_dir}"

    export pgm=${FUNCNAME}

    echo "This is a file with text in it" > ${test_dir}/source_dir/file1.txt
    
    $TARGET_SCRIPT -z -pr ${test_dir}/source_dir/file* ${test_dir}/target_dir 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err

    err_msg=$( egrep "FATAL ERROR|illegal" ${test_dir}/${FUNCNAME}.err )

    test -z "$err_msg"
    check_results ${FUNCNAME} $? "$err_msg"
}


test_multiple_cp_opts_zero_byte() {
    # --------------------------------------
    # Test with '-z' and multiple cp options
    # --------------------------------------
    test_dir=${TMP_DIR}/${FUNCNAME}
    setup "${test_dir}"

    export pgm=${FUNCNAME}

    touch ${test_dir}/source_dir/file1.txt ${test_dir}/target_dir 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err

    err_msg=$( grep "FATAL ERROR" ${test_dir}/${FUNCNAME}.err )

    test -z "$err_msg"
    check_results ${FUNCNAME} $? "$err_msg"
}

test_cp_opt_t() {
    # ----------------------
    # Test with cp -t option
    # ----------------------
    test_dir=${TMP_DIR}/${FUNCNAME}
    setup "${test_dir}"

    export pgm=${FUNCNAME}

    echo "This is a file with text in it" > ${test_dir}/source_dir/file1.txt

    $TARGET_SCRIPT -t ${test_dir}/target_dir ${test_dir}/source_dir/file1.txt 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err

    err_msg=$( grep "FATAL ERROR" ${test_dir}/${FUNCNAME}.err )

    test -z "$err_msg" -a -s ${test_dir}/target_dir/file1.txt
    check_results ${FUNCNAME} $? "$err_msg"
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
    wrapper "test_one_empty_file_no_opt"
    wrapper "test_one_empty_file_opt"
    wrapper "test_multiple_files"
    wrapper "test_multiple_empty_files_no_opt"
    wrapper "test_multiple_empty_files_opt"
    wrapper "test_mixed_files_no_opt"
    wrapper "test_mixed_files_opt"
    wrapper "test_directory_no_opt"
    wrapper "test_directory_opt"
    wrapper "test_one_cp_opt"
    wrapper "test_one_cp_opt_zero_byte"
    wrapper "test_multiple_cp_opts"
    wrapper "test_multiple_cp_opts_zero_byte"
    wrapper "test_cp_opt_t"
    echo "====================================="

    echo "Summary"
    echo "Passed: ${NPASSED}"
    echo "Failed: ${NFAILED}"
}

main
