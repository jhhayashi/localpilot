VENV_NAME=localpilot

create-venv:
	eval "$$(pyenv init -)" && \
	eval "$$(pyenv virtualenv-init -)" && \
	if ! (pyenv versions | grep -q "${VENV_NAME}"); then pyenv virtualenv "${VENV_NAME}"; fi

# ensure the venv is active. it's finicky trying to activate a venv inside make
check-venv: create-venv
	@if [ -z "$${VIRTUAL_ENV}" ]; then \
		echo "Virtual environment is not active! Please activate $(VENV_NAME) with the following command before proceeding."; \
		echo "pyenv activate ${VENV_NAME}"
		exit 1; \
	fi
	@if [ "$$(pyenv version-name)" != "$(VENV_NAME)" ]; then \
		echo "Active virtual environment is not $(VENV_NAME)! Please activate $(VENV_NAME) before proceeding."; \
		exit 1; \
	fi

build: check-venv
	pip install -r requirements.txt
	pip uninstall llama-cpp-python -y
	CMAKE_ARGS="-DLLAMA_METAL=on" pip install -U llama-cpp-python==0.2.27 --no-cache-dir
	pip install 'llama-cpp-python[server]'
	python app.py --setup 

start: check-venv
	python app.py
