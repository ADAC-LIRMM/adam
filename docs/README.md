## Documentation Generation

This project uses Sphinx to generate its documentation. 
Here are the steps to generate the documentation:

1. Ensure you have Sphinx installed. If not, you can install it using pip:

    ```bash
    pip install sphinx
    ```

    Additionally, install the Sphinx RTD theme by running the following command:

    ```bash
    pip install sphinx_rtd_theme
    ```

2. Navigate to the `docs` directory:

    ```bash
    cd docs
    ```

3. Run the make command to generate the documentation. 
For example, to generate HTML documentation, you would use:

    ```bash
    make html
    ```

    This will generate a `build/html` directory with the HTML version of the 
    documentation.

You can replace `html` with `latexpdf` to generate a PDF version of the 
documentation, or with `epub` to generate an EPUB version. 
For a full list of available formats, run `make help`.