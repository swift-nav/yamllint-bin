def make_dist():
    return default_python_distribution()

def make_exe(dist):
    policy = dist.make_python_packaging_policy()
    python_config = dist.make_python_interpreter_config()

    python_config.run_mode = 'module:yamllint'

    exe = dist.to_python_executable(
        name="yamllint",
        packaging_policy=policy,
        config=python_config,
    )

    #exe.add_python_resources(exe.pip_install(["pyyaml", "--global-option=--without-libyaml"]))
    exe.add_python_resources(exe.pip_install(["./yamllint"]))

    return exe

def make_embedded_resources(exe):
    return exe.to_embedded_resources()

def make_install(exe):
    files = FileManifest()
    files.add_python_resource(".", exe)

    return files

register_target("dist", make_dist)
register_target("exe", make_exe, depends=["dist"])
register_target("resources", make_embedded_resources, depends=["exe"], default_build_script=True)
register_target("install", make_install, depends=["exe"], default=True)

resolve_targets()

# END OF COMMON USER-ADJUSTED SETTINGS.
#
# Everything below this is typically managed by PyOxidizer and doesn't need
# to be updated by people.

PYOXIDIZER_VERSION = "0.9.0"
PYOXIDIZER_COMMIT = "UNKNOWN"
