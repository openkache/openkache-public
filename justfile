# Keep the empty workspace usable while applying the same checks to every
# package once members are added.

fmt:
    @if cargo metadata --no-deps --format-version 1 | grep -Fq '"packages":[]'; then \
        echo "fmt: no workspace packages"; \
    else \
        cargo fmt --all -- --check; \
    fi

# Verify advisories, licenses, bans, sources, and version policy. Cargo-deny
# cannot construct a graph for a virtual workspace with no members yet, so
# keep the foundation green until the first public crate is added.
check-deps:
    @if cargo metadata --no-deps --format-version 1 | grep -Fq '"packages":[]'; then \
        echo "check-deps: no workspace packages"; \
    else \
        cargo deny --locked check advisories bans sources licenses; \
    fi

lint: check-deps
    @if cargo metadata --no-deps --format-version 1 | grep -Fq '"packages":[]'; then \
        echo "lint: no workspace packages"; \
    else \
        cargo clippy --workspace --all-targets --all-features -- -D warnings; \
    fi

test:
    @if cargo metadata --no-deps --format-version 1 | grep -Fq '"packages":[]'; then \
        echo "test: no workspace packages"; \
    else \
        cargo test --workspace --all-features; \
    fi

presubmit: fmt lint test check-deps
