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
    func_name=$1
    test_dir=${TMP_DIR}/${func_name}
    source_dir=${test_dir}/source_dir
    target_dir=${test_dir}/target_dir
    mkdir -p ${source_dir}
    mkdir -p ${target_dir}

    export pgm=${func_name}

    echo "${test_dir}"
}


wrapper() {
    func=$1

    test_dir=$( setup "$func" )
    export test_dir

    ${func} "${test_dir}"
    echo "----------------------------"

    teardown
}


teardown() {
    unset pgm
    unset test_dir
}


check_results() {
    func_name=$1
    err=$2
    err_msg=$3

    target_script=$( basename "$TARGET_SCRIPT" )

    if [[ $err -eq 0 ]]; then
        echo "PASSED: ${target_script}:${func_name}"
        export NPASSED=$(( NPASSED + 1 ))
    else
        echo "FAILED: ${target_script}:${func_name}"
        echo "$err_msg"
        export NFAILED=$(( NFAILED + 1))
    fi
}

err_chk() {
    /lfs/h1/nco/idsb/noscrub/russell.manser/git_repos/prod_util/tests/patch/err_chk "$*"
}

err_exit() {
    export msg="$1"
    /lfs/h1/nco/idsb/noscrub/russell.manser/git_repos/prod_util/tests/patch/err_exit
}

# ----------
# Test suite
# ----------


test_one_file() {
    # -------------------------------------------------
    # Test that cpreq copies a single nonzero size file
    # -------------------------------------------------
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
    # Test that 'cp' is successful for the same conditions
    # -------------------------------------------------------
    touch ${test_dir}/source_dir/file.txt
    $TARGET_SCRIPT ${test_dir}/source_dir/file.txt ${test_dir}/target_dir 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err

    err_msg=$( grep "FATAL ERROR: return code 2" ${test_dir}/${FUNCNAME}.err )

    if [[ "$TARGET_SCRIPT" =~ cpreq ]]; then
        test ! -z "$err_msg"
        err=$?
    elif [[ "$TARGET_SCRIPT" = "cp" ]]; then
        test -z "$err_msg"
        err=$?
    else
        echo "$TARGET_SCRIPT is not a valid test option for $FUNCNAME" >&2
        err=3
    fi
    check_results ${FUNCNAME} $err "$err_msg"
}


test_one_empty_file_opt() {
    # ------------------------------------------------------
    # Test that cpreq copys a single zero size file with the
    # '-z' option specified
    # ------------------------------------------------------
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
    # Test that 'cp' is successful for the same conditions
    # -----------------------------------------------------
    for i in $( seq 1 3 ); do
        touch ${test_dir}/source_dir/file${i}.txt
    done

    $TARGET_SCRIPT ${test_dir}/source_dir/file* ${test_dir}/target_dir 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err

    err_msg=$( grep "FATAL ERROR: return code 2" ${test_dir}/${FUNCNAME}.err )

    if [[ "$TARGET_SCRIPT" =~ cpreq ]]; then
        test ! -z "$err_msg"
        err=$?
    elif [[ "$TARGET_SCRIPT" = "cp" ]]; then
        test -z "$err_msg"
        err=$?
    else
        echo "$TARGET_SCRIPT is not a valid test option for $FUNCNAME" >&2
        err=3
    fi

    check_results ${FUNCNAME} $err "$err_msg"
}


test_multiple_empty_files_opt() {
    # ---------------------------------------------------
    # Test the cpreq copies multiple zero size files with
    # the '-z' option specified
    # ---------------------------------------------------
    for i in $( seq 1 3 ); do
        touch ${test_dir}/source_dir/file${i}.txt
    done

    $TARGET_SCRIPT -z ${test_dir}/source_dir/file* ${test_dir}/target_dir 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err

    err_msg=$( grep "FATAL ERROR" ${test_dir}/${FUNCNAME}.err )

    test -z "$err_msg"
    check_results ${FUNCNAME} $? "$err_msg"
}


test_mixed_files_no_opt() {
    # ----------------------------------------------------
    # Test that cpreq *fails* to copy multiple files when
    # one or more are size zero and '-z' is not specified
    #
    # Test that 'cp' is successful for the same conditions
    # ----------------------------------------------------
    echo "This is a file with text in it" > ${test_dir}/source_dir/file1.txt
    touch ${test_dir}/source_dir/file2.txt

    $TARGET_SCRIPT ${test_dir}/source_dir/file* ${test_dir}/target_dir 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err

    err_msg=$( grep "FATAL ERROR: return code 2" ${test_dir}/${FUNCNAME}.err )

    if [[ "$TARGET_SCRIPT" =~ cpreq ]]; then
        test ! -z "$err_msg"
        err=$?
    elif [[ "$TARGET_SCRIPT" = "cp" ]]; then
        test -z "$err_msg"
        err=$?
    else
        echo "$TARGET_SCRIPT is not a valid test option for $FUNCNAME" >&2
        err=3
    fi

    check_results ${FUNCNAME} $err "$err_msg"
}


test_mixed_files_opt() {
    # -------------------------------------------------
    # Test that cpreq copies multiple files when one or
    # more are size zero and '-z' is specified
    # -------------------------------------------------
    echo "This is a file with text in it" > ${test_dir}/source_dir/file1.txt
    touch ${test_dir}/source_dir/file2.txt

    $TARGET_SCRIPT -z ${test_dir}/source_dir/file* ${test_dir}/target_dir 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err
    
    err_msg=$( grep "FATAL ERROR" ${test_dir}/${FUNCNAME}.err )

    test -z "$err_msg"
    check_results ${FUNCNAME} $? "$err_msg"
}


test_directory_no_opt() {
    # ----------------------------------------------------
    # Test that copying a directory with an empty file
    # *fails* without '-z'
    #
    # Test that 'cp' is successful for the same conditions
    # ----------------------------------------------------
    echo "This is a file with text in it" > ${test_dir}/source_dir/file1.txt
    touch ${test_dir}/source_dir/file2.txt

    $TARGET_SCRIPT -r ${test_dir}/source_dir/ ${test_dir}/target_dir 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err

    err_msg=$( grep "FATAL ERROR: return code 2" ${test_dir}/${FUNCNAME}.err )

    if [[ "$TARGET_SCRIPT" =~ cpreq ]]; then
        test ! -z "$err_msg"
        err=$?
    elif [[ "$TARGET_SCRIPT" = "cp" ]]; then
        test -z "$err_msg"
        err=$?
    else
        echo "$TARGET_SCRIPT is not a valid test option for $FUNCNAME" >&2
        err=3
    fi

    check_results ${FUNCNAME} $err "$err_msg"
}


test_directory_opt() {
    # --------------------------------------
    # Test copying a directory recursively
    # which contains an empty file with '-z'
    # --------------------------------------
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
    echo "This is a file with text in it" > ${test_dir}/source_dir/file1.txt
    
    $TARGET_SCRIPT -z -pr ${test_dir}/source_dir/file* ${test_dir}/target_dir 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err

    err_msg=$( grep -E "FATAL ERROR|illegal" ${test_dir}/${FUNCNAME}.err )

    test -z "$err_msg"
    check_results ${FUNCNAME} $? "$err_msg"
}


test_multiple_cp_opts_zero_byte() {
    # --------------------------------------
    # Test with '-z' and multiple cp options
    # --------------------------------------
    touch ${test_dir}/source_dir/file1.txt ${test_dir}/target_dir 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err

    err_msg=$( grep "FATAL ERROR" ${test_dir}/${FUNCNAME}.err )

    test -z "$err_msg"
    check_results ${FUNCNAME} $? "$err_msg"
}

test_cp_opt_t() {
    # ----------------------
    # Test with cp -t option
    # ----------------------
    echo "This is a file with text in it" > ${test_dir}/source_dir/file1.txt

    $TARGET_SCRIPT -t ${test_dir}/target_dir ${test_dir}/source_dir/file1.txt 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err

    err_msg=$( grep "FATAL ERROR" ${test_dir}/${FUNCNAME}.err )

    test -z "$err_msg" -a -s ${test_dir}/target_dir/file1.txt
    check_results ${FUNCNAME} $? "$err_msg"
}

test_cp_opt_long_form() {
    # ---------------------------
    # Test with long form options
    # ---------------------------
    echo "This is a file with text in it" > ${test_dir}/source_dir/file1.txt

    $TARGET_SCRIPT --preserve=ownership --no-clobber ${test_dir}/source_dir/file1.txt ${test_dir}/target_dir/ 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err

    err_msg=$( grep "FATAL ERROR" ${test_dir}/${FUNCNAME}.err )

    test -z "$err_msg"
    check_results ${FUNCNAME} $? "$err_msg"
}

test_cp_opt_long_form_zero_byte() {
    # ------------------------------------
    # Test with '-z' and long form options
    # ------------------------------------
    echo "This is a file with test in it" > ${test_dir}/source_dir/file1.txt
    touch ${test_dir}/source_dir/file2.txt

    $TARGET_SCRIPT -z --preserve=ownership --no-clobber ${test_dir}/source_dir/file* ${test_dir}/target_dir/ 1> ${test_dir}/${FUNCNAME}.out 2> ${test_dir}/${FUNCNAME}.err

    err_msg=$( grep "FATAL ERROR" ${test_dir}/${FUNCNAME}.err )

    test -z "$err_msg"
    check_results ${FUNCNAME} $? "$err_msg"
}


# -----------
# Main script
# -----------

main() {
    export -f err_chk
    export -f err_exit

    TMP_ROOT="/lfs/h1/nco/stmp/$( whoami )"
    export TMP_DIR="${TMP_ROOT}/test_cpreq_$(date +%Y%m%d_%H%M_%N)"
    echo "Test directory: ${TMP_DIR}"

    PKG_ROOT=$( pwd )
    export TARGET_SCRIPT=${PKG_ROOT}/ush/cpreq

    export NPASSED=0
    export NFAILED=0

    echo "====================================="
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
    wrapper "test_cp_opt_long_form"
    wrapper "test_cp_opt_long_form_zero_byte"

    export TARGET_SCRIPT="cp"

    wrapper "test_one_file"
    wrapper "test_one_empty_file_no_opt"
    wrapper "test_multiple_files"
    wrapper "test_multiple_empty_files_no_opt"
    wrapper "test_mixed_files_no_opt"
    wrapper "test_directory_no_opt"
    wrapper "test_one_cp_opt"
    wrapper "test_multiple_cp_opts"
    wrapper "test_cp_opt_t"
    wrapper "test_cp_opt_long_form"
    echo "====================================="

    echo "Summary"
    echo "Passed: ${NPASSED}"
    echo "Failed: ${NFAILED}"
}

main
