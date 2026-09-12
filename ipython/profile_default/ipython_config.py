c = get_config()  # noqa: F821

# Deliberately left without a forced matplotlib backend: this profile is
# also what Jupyter notebook kernels load by default, and forcing "qt"
# here made notebook figures pop out as floating windows instead of
# rendering inline. The floating-window behavior for iron.nvim/ipython
# lives in profile_iron instead (see ~/.ipython/profile_iron/ and
# nvim-lab's lua/plugins/iron.lua, which launches ipython with
# --profile=iron).
