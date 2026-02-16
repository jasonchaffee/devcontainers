#!/bin/bash
# Build the Development Container base image

set -e

IMAGE_NAME="devcontainer-base"
IMAGE_TAG="${2:-latest}"

usage() {
    echo "Usage: ./build.sh [command] [tag]"
    echo ""
    echo "Commands:"
    echo "  build   Build base image only (default)"
    echo "  test    Build and test with devcontainer CLI (includes features)"
    echo "  shell   Start container and open shell"
    echo ""
    echo "Examples:"
    echo "  ./build.sh              # Build base image"
    echo "  ./build.sh build v1.0   # Build with custom tag"
    echo "  ./build.sh test         # Build and test full devcontainer"
    echo "  ./build.sh shell        # Open shell in running container"
}

build_base() {
    echo "============================================================================"
    echo "Building Development Container (Base Image)"
    echo "============================================================================"
    echo ""
    echo "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
    echo ""

    # Build with BuildKit for better caching and performance
    DOCKER_BUILDKIT=1 docker build \
        -t "${IMAGE_NAME}:${IMAGE_TAG}" \
        -f Dockerfile \
        .

    echo ""
    echo "============================================================================"
    echo "Build Complete!"
    echo "============================================================================"
    echo ""
    echo "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
    echo "Size:  $(docker images ${IMAGE_NAME}:${IMAGE_TAG} --format "{{.Size}}")"
    echo ""
    echo "Next steps:"
    echo "  1. Run './build.sh test' to test the full devcontainer"
    echo "  2. Or use a template from templates/ in your service repo"
    echo ""
}

test_devcontainer() {
    echo "============================================================================"
    echo "Testing Development Container"
    echo "============================================================================"
    echo ""

    # Check if devcontainer CLI is installed
    if ! command -v devcontainer &> /dev/null; then
        echo "Error: devcontainer CLI not found"
        echo ""
        echo "Install with:"
        echo "  npm install -g @devcontainers/cli"
        echo "  # or"
        echo "  brew install devcontainer"
        exit 1
    fi

    # First build the base image
    echo "Step 1: Building base image..."
    build_base

    echo ""
    echo "Step 2: Building devcontainer with features..."
    echo ""

    # Build with devcontainer CLI (processes features, etc.)
    devcontainer build --workspace-folder .

    echo ""
    echo "Step 3: Starting container and running tests..."
    echo ""

    # Start container
    devcontainer up --workspace-folder .

    # Run test commands
    echo "Testing installed tools..."
    echo ""

    echo "Zsh version:"
    devcontainer exec --workspace-folder . zsh --version

    echo ""
    echo "Git version:"
    devcontainer exec --workspace-folder . git --version

    echo ""
    echo "SSL certificate test:"
    devcontainer exec --workspace-folder . curl -s https://www.google.com -o /dev/null && echo "SSL: OK" || echo "SSL: FAILED"

    echo ""
    echo "============================================================================"
    echo "Test Complete!"
    echo "============================================================================"
    echo ""
    echo "Container is running. To open a shell:"
    echo "  ./build.sh shell"
    echo ""
    echo "To stop the container:"
    echo "  docker stop \$(docker ps -q --filter ancestor=${IMAGE_NAME})"
    echo ""
}

open_shell() {
    echo "Opening shell in devcontainer..."
    devcontainer exec --workspace-folder . zsh
}

# Parse command
case "${1:-build}" in
    build)
        build_base
        ;;
    test)
        test_devcontainer
        ;;
    shell)
        open_shell
        ;;
    -h|--help|help)
        usage
        ;;
    *)
        echo "Unknown command: $1"
        echo ""
        usage
        exit 1
        ;;
esac
