#!/usr/bin/env bats
#
# Copyright (c) 2019 Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0
#

load "${BATS_TEST_DIRNAME}/../../common.bash"
load "${BATS_TEST_DIRNAME}/tests_common.sh"

setup() {
	[ "${KATA_HYPERVISOR}" = "qemu-tdx" ] && skip "See: https://github.com/kata-containers/kata-containers/issues/9666"
	[ "${KATA_HYPERVISOR}" = "qemu-sev" ] && skip "See: https://github.com/kata-containers/kata-containers/issues/9666"

	pod_name="sysctl-test"
	get_pod_config_dir

	yaml_file="${pod_config_dir}/pod-sysctl.yaml"
	add_allow_all_policy_to_yaml "${yaml_file}"
}

@test "Setting sysctl" {
	# Create pod
	kubectl apply -f "${yaml_file}"

	# Check pod creation
	kubectl wait --for=condition=Ready --timeout=$timeout pod $pod_name

	# Check sysctl configuration
	cmd="cat /proc/sys/kernel/shm_rmid_forced"
	result=$(kubectl exec $pod_name -- sh -c "$cmd")
	[ "${result}" = 0 ]
}

teardown() {
	[ "${KATA_HYPERVISOR}" = "qemu-tdx" ] && skip "See: https://github.com/kata-containers/kata-containers/issues/9666"
	[ "${KATA_HYPERVISOR}" = "qemu-sev" ] && skip "See: https://github.com/kata-containers/kata-containers/issues/9666"

	# Debugging information
	kubectl describe "pod/$pod_name"

	kubectl delete pod "$pod_name"
}
