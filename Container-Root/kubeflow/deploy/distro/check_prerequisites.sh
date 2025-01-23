#!/bin/bash

# Global flag to track if all checks are passed
ALL_CHECKS_PASSED=true

# Function to check for the CRD 'mpijob.kubeflow.org'
check_mpijobs() {
    echo ""
    if kubectl get crd mpijobs.kubeflow.org &>/dev/null; then
        echo "CRD 'mpijobs.kubeflow.org' is installed."
        # Extract the version of the CRD
        VERSION=$(kubectl get crd mpijobs.kubeflow.org -o jsonpath='{.spec.versions[0].name}')
        echo "Version of 'mpijobs.kubeflow.org': $VERSION"
        if [ "$VERSION" != "v1" ]; then
            echo "Version mismatch: Expected 'v1' but found '$VERSION'."
            echo "Please remove the current installation of 'mpijob.kubeflow.org' to avoid conflicts when deploying Kubeflow. Afterwards, please re-run this script."
            ALL_CHECKS_PASSED=false
        fi
    else
        echo ""
    fi
}

# Function to check if Istio is installed
check_istio() {
    echo "Checking if Istio is installed..."
    if kubectl get pods -n istio-system --no-headers 2>/dev/null | grep -q '.'; then
        echo "Istio appears to be installed (pods found in 'istio-system' namespace)."
        echo "Please remove your istio installation to avoid any conflicts in the Kubeflow deployment. Afterwards, please re-run this script."
        ALL_CHECKS_PASSED=false
    else
        echo ""
    fi
}

# Function to check if a default storage class exists
check_default_storage_class() {
    echo "Checking for default StorageClass..."
    DEFAULT_STORAGE_CLASS=$(kubectl get storageclass -o jsonpath='{.items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")].metadata.name}')
    if [ -n "$DEFAULT_STORAGE_CLASS" ]; then
        PROVISIONER=$(kubectl get storageclass "$DEFAULT_STORAGE_CLASS" -o jsonpath='{.provisioner}')
        echo "Default StorageClass is set up: $DEFAULT_STORAGE_CLASS (Provisioner: $PROVISIONER)."
    else
        echo "No default StorageClass is set up. In order to deploy Kubeflow, a default StorageClass is required in your EKS cluster. Please create a default StorageClass (You can follow the instructions in the README on how to do this). Afterwards, please re-run this script."
        ALL_CHECKS_PASSED=false
    fi
}
# Main function
main() {
    echo "Starting EKS cluster checks..."
    
    # Perform checks
    check_mpijobs
    check_istio
    check_default_storage_class

    # Output the result of all checks
    if [ "$ALL_CHECKS_PASSED" = true ]; then
        echo "All checks passed successfully."
        export ALL_CHECKS_PASSED=true
    else
        echo "One or more checks failed."
        export ALL_CHECKS_PASSED=false
    fi
}

# Run main function
main
