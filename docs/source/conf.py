# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'ADAM'
copyright = '2023, LIRMM'
author = 'LIRMM'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    'sphinx_rtd_theme',
    #'sphinxcontrib.wavedrom'
]

templates_path = ['_templates']
exclude_patterns = []

# -- Options for HTML output -------------------------------------------------

html_theme = 'sphinx_rtd_theme'
#html_static_path = ['_static']

# -- Options for Latex output ------------------------------------------------

latex_elements = {
    'preamble': r'\usepackage{adam}',
}
latex_additional_files = ["adam.sty"]