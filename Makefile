.PHONY: install precommit

install:
	pip install pre-commit
	pre-commit install

precommit:
	pre-commit run --all-files
