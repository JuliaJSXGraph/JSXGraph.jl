### A Pluto.jl notebook ###
# v0.20.23

using Markdown
using InteractiveUtils

# ╔═╡ b9e879b4-1950-11f1-a511-cd1da4badc3c
begin
	using Pkg
	#Pkg.add(PackageSpec(url="https://github.com/s-celles/JSXGraph.jl"))
	Pkg.develop(PackageSpec(path="../.."))
	using JSXGraph
end

# ╔═╡ 0a4a0311-0544-4b0a-8251-8793a5158b6d
begin
	function plot_multiple_functions()
		b = Board("multi_func", xlim=(-5, 5), ylim=(-3, 3))
		push!(b, functiongraph("Math.sin(x)"; strokeColor="blue", strokeWidth=2, name="sin"))
		push!(b, functiongraph("Math.cos(x)"; strokeColor="red", strokeWidth=2, name="cos"))
		push!(b, functiongraph("Math.sin(x) + Math.cos(x)"; strokeColor="green",
		          strokeWidth=2, name="sin+cos", dash=2))
		b
	end
	plot_multiple_functions()
end

# ╔═╡ 654abbe2-43d9-44fb-8d95-204aaa3bd2d0
begin
	function plot_surface_plot_sine_wave()
		b = board("sine_surface", xlim=(-8, 8), ylim=(-8, 8)) do b
		    v = view3d([-6, -3], [8, 8], [[-5, 5], [-5, 5], [-2, 2]]) do v
		        push!(v, functiongraph3d("Math.sin(x)*Math.cos(y)";
		            strokeWidth=0.5,
		            stepsU=40, stepsV=40,
		        ))
		    end
		    push!(b, v)
		end
		b
	end
	plot_surface_plot_sine_wave()
end

# ╔═╡ Cell order:
# ╠═b9e879b4-1950-11f1-a511-cd1da4badc3c
# ╠═0a4a0311-0544-4b0a-8251-8793a5158b6d
# ╠═654abbe2-43d9-44fb-8d95-204aaa3bd2d0
