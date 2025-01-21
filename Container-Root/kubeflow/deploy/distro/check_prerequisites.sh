#!/bin/bash

# Global flag to track if all checks are passed
ALL_CHECKS_PASSED=true

# Function to check for the CRD 'mpijob.kubeflow.org'
check_mpijobs() {
    echo "Checking for CRD 'mpijobs.kubeflow.org'..."
    if kubectl get crd mpijobs.kubeflow.org &>/dev/null; then
        echo "CRD 'mpijobs.kubeflow.org' is installed."
        # Extract the version of the CRD
        VERSION=$(kubectl get crd mpijobs.kubeflow.org -o jsonpath='{.spec.versions[0].name}')
        echo "Version of 'mpijobs.kubeflow.org': $VERSION"
        if [ "$VERSION" != "v1" ]; then
            echo "Version mismatch: Expected 'v1' but found '$VERSION'."
            echo "Please remove the current installation of 'mpijob.kubeflow.org' to avoid conflicts when deploying Kubeflow"
            ALL_CHECKS_PASSED=false
        fi
    else
        echo "CRD 'mpijobs.kubeflow.org' is NOT installed."
    fi
}

# Function to check if Istio is installed
check_istio() {
    echo "Checking if Istio is installed..."
    if kubectl get pods -n istio-syst --no-headers 2>/dev/null | grep -q '.'; then
        echo "Istio appears to be installed (pods found in 'istio-system' namespace)."
        echo "Please remove your istio installation to avoid any conflicts in the Kubeflow deployment. Alternatively please exclude istio from the Kubeflow deployment."
        ALL_CHECKS_PASSED=false
    else
        echo "Istio is NOT installed or no pods are running in the 'istio-system' namespace."
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
        echo "No default StorageClass is set up."
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
