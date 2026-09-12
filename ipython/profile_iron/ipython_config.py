c = get_config()  # noqa: F821

# Used only by the terminal ipython that iron.nvim launches (see
# nvim-lab's lua/plugins/iron.lua, which passes --profile=iron). Kept out
# of profile_default because Jupyter notebook kernels load profile_default
# too, and this qt event-loop hook makes matplotlib pop figures in floating
# windows instead of rendering them inline in a notebook.
c.InteractiveShellApp.matplotlib = "qt"
