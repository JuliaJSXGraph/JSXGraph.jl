module JSXGraphNodeJSExt

using JSXGraph
using NodeJS_22_jll: NodeJS_22_jll

"""
    _ensure_npm_package(pkg::String)

Ensure an npm package is installed in the package-local node_modules directory.
Installs it automatically on first use via the JLL-provided npm.
"""
function _ensure_npm_package(pkg::String)
    deps_dir = JSXGraph._node_modules_dir()
    # Handle scoped packages (@scope/pkg → @scope/pkg under node_modules)
    pkg_dir = joinpath(deps_dir, "node_modules", pkg)
    if isdir(pkg_dir)
        return  # already installed
    end
    mkpath(deps_dir)
    @info "Installing $pkg for export (one-time setup)..."
    cmd = Cmd(`$(NodeJS_22_jll.npm_path) install --prefix $deps_dir $pkg`; dir=deps_dir)
    run(pipeline(cmd; stdout=devnull, stderr=devnull); wait=true)
    if !isdir(pkg_dir)
        error("Failed to install $pkg. Try manually: `cd $deps_dir && npm install $pkg`")
    end
    @info "$pkg installed successfully."
end

"""
    _run_node_script(script::String) -> (String, String)

Write a Node.js script to a temp file, run it with NODE_PATH set,
and return (stdout, stderr).
"""
function _run_node_script(script::String)
    deps_dir = JSXGraph._node_modules_dir()
    script_path = tempname() * ".js"
    try
        write(script_path, script)
        node_modules = joinpath(deps_dir, "node_modules")
        env = copy(ENV)
        env["NODE_PATH"] = node_modules

        output = IOBuffer()
        errors = IOBuffer()
        cmd = Cmd(`$(NodeJS_22_jll.node_path) $script_path`; env=env)
        run(pipeline(cmd; stdout=output, stderr=errors); wait=true)

        return (String(take!(output)), String(take!(errors)))
    finally
        rm(script_path; force=true)
    end
end

# --- SVG Export ---

function JSXGraph.save_svg(filename::String, board::JSXGraph.Board)
    _ensure_npm_package("jsdom")

    script = JSXGraph._svg_export_script(board)
    stdout_content, stderr_content = _run_node_script(script)

    if isempty(stdout_content)
        error("SVG export produced no output. Errors:\n$stderr_content")
    end

    open(filename, "w") do io
        write(io, stdout_content)
    end
    return filename
end

# --- PNG Export ---

function JSXGraph.save_png(filename::String, board::JSXGraph.Board; scale::Int=1)
    _ensure_npm_package("jsdom")
    _ensure_npm_package("sharp")

    script = JSXGraph._png_export_script(board, filename; scale=scale)
    _, stderr_content = _run_node_script(script)

    if !isfile(filename)
        error("PNG export failed to create file. Errors:\n$stderr_content")
    end
    return filename
end

# --- PDF Export ---

function JSXGraph.save_pdf(filename::String, board::JSXGraph.Board)
    _ensure_npm_package("jsdom")
    _ensure_npm_package("pdfkit")
    _ensure_npm_package("svg-to-pdfkit")

    script = JSXGraph._pdf_export_script(board, filename)
    _, stderr_content = _run_node_script(script)

    if !isfile(filename)
        error("PDF export failed to create file. Errors:\n$stderr_content")
    end
    return filename
end

end # module JSXGraphNodeJSExt
