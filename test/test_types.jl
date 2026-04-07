@testset "Core Types" begin
    @test isabstracttype(AbstractJSXElement)
    @test isconcretetype(Board)
    @test !(Board <: AbstractJSXElement)

    # Board constructor
    b = Board("test", AbstractJSXElement[], Dict{String,Any}())
    @test b.id == "test"
    @test b.elements == AbstractJSXElement[]
    @test b.options == Dict{String,Any}()

    # Board field types
    @test fieldtype(Board, :id) == String
    @test fieldtype(Board, :elements) == Vector{AbstractJSXElement}
    @test fieldtype(Board, :options) == Dict{String,Any}
end

@testset "Extensions" begin
    @testset "Colors Extension" begin
        using Colors
        ext = Base.get_extension(JSXGraph, :JSXGraphColorsExt)
        @test ext !== nothing
    end

    @testset "Unitful Extension" begin
        using Unitful
        ext = Base.get_extension(JSXGraph, :JSXGraphUnitfulExt)
        @test ext !== nothing
    end

    @testset "Tables Extension" begin
        using Tables
        ext = Base.get_extension(JSXGraph, :JSXGraphTablesExt)
        @test ext !== nothing
    end

    @testset "Observables Extension" begin
        using Observables
        ext = Base.get_extension(JSXGraph, :JSXGraphObservablesExt)
        @test ext !== nothing
    end

    @testset "DefaultApplication Extension" begin
        using DefaultApplication
        ext = Base.get_extension(JSXGraph, :JSXGraphDefaultApplicationExt)
        @test ext !== nothing
    end
end

@testset "Board Keyword Constructor" begin
    # Default options
    b1 = Board("b1")
    @test b1.id == "b1"
    @test b1.options["axis"] == true
    @test isempty(b1.elements)
    @test !isempty(b1.options)

    # Custom bounding box from xlim/ylim
    b2 = Board("b2", xlim=(-10, 10), ylim=(-5, 5))
    @test b2.options["boundingbox"] == [-10, 5, 10, -5]

    # Grid and dimensions
    b3 = Board("b3", grid=true, width=600, height=400)
    @test b3.options["grid"] == true
    @test b3.options["width"] == 600
    @test b3.options["height"] == 400

    # Auto-generated id when empty
    b4 = Board("", xlim=(-5, 5), ylim=(-5, 5))
    @test !isempty(b4.id)

    # Default elements and options
    b5 = Board("b5")
    @test isempty(b5.elements)
    @test !isempty(b5.options)
end

@testset "JSXElement Type" begin
    @test JSXElement <: AbstractJSXElement
    @test isconcretetype(JSXElement)

    # Constructor
    el = JSXElement("point", Any[1, 2], Dict{String,Any}())
    @test el.type_name == "point"
    @test el.parents == Any[1, 2]
    @test el.attributes == Dict{String,Any}()

    # JSFunction
    jf = JSFunction("function(x){return x;}")
    @test jf.code == "function(x){return x;}"
end
