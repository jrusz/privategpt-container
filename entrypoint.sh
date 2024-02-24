#!/bin/bash

ln -sf /.venv /app/.venv
exec "$@"
