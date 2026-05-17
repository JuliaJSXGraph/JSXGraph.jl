# FunctionGraph

@testset "ex-fg" begin
    b = board("brd", shownavigation=true, showscreenshot=true)
    b ++ slider("a", [[1, -1], [5, -1], [0, 1.5, 3]])
    b ++ @jsf foo(x) = val(a)*x^2
    b ++ functiongraph(foo, dash=2)
    s = str(b, preamble=false)
    @test isapproxstr(
        s,
        """(function(){
function foo(x){return (val(a)*Math.pow(x,2))};
var brd = JXG.JSXGraph.initBoard("brd",
        {"boundingbox":[-10,10,10,-10],
         "axis":false,
         "showcopyright":false,
         "shownavigation":true,
         "showscreenshot":true});
var a = brd.create(
        'slider',
        [[1.0,-1.0],[5.0,-1.0],[0.0,1.5,3.0]],
        {});
brd.create(
        'functiongraph',
        [function(t){return foo(t);}, -10, 10],
        {"dash":2});})();
""",
    )
end

# ParametricCurve
@testset "ex-pc" begin
    b = board("brd", xlim=[-1, 15], ylim=[-0.5, 2.5])
    @jsf f1(t) = t - sin(t)
    @jsf f2(t) = 1 - cos(t)
    sT = slider("T", [[0, 2.1], [3, 2.1], [0, π, 5π]])
    @jsf fb() = val(T)
    @jsf pa() = f1(val(T))
    @jsf pb() = f2(val(T))
    b ++ (f1, f2, sT, fb, pa, pb)
    b ++ plot(f1, f2; a=0, b=fb, dash=2)
    b ++ point(pa, pb, withlabel=false)
    s = str(b, preamble=false)
    @test isapproxstr(
        s,
        """(function(){
function f1(t){return (t-sin(t))};
function f2(t){return (1-cos(t))};
function fb(){return val(T)};
function pa(){return f1(val(T))};
function pb(){return f2(val(T))};
var brd=JXG.JSXGraph.initBoard("brd",
        {"boundingbox":[-1.0,2.5,15.0,-0.5],
        "axis":false,
        "showcopyright":false,
        "shownavigation":false});
var T=brd.create(
        'slider',
        [[0.0,2.1],[3.0,2.1],[0.0,3.141592653589793,15.707963267948966]], {});
brd.create(
        'curve',
        [function(t){return f1(t);}, function(t){return f2(t);},
          0, function(t){return fb(t);}],
        {"dash":2});
brd.create(
        'point',
        [function(t){return pa(t);}, function(t){return pb(t);}],
        {"withlabel":false});})();
""",
    )
end

# DataPlot
@testset "ex-dp" begin
    b = board("b", xlim=[0, 1], ylim=[0, 1])
    x = [1, 2, 3, 4]
    y = [1, 2, 3, 4]
    b ++ plot(x, y)
    s = str(b, preamble=false)
    @test isapproxstr(
        s,
        """(function(){
var b=JXG.JSXGraph.initBoard("b"
        ,
        {"boundingbox":[0,1,1,0],
        "axis":false,
        "showcopyright":false,
        "shownavigation":false});
b.create('curve', [[1,2,3,4], [1,2,3,4]], {});})();
""",
    )
end

# Lissajou
@testset "ex-li" begin
    b = board("brd", xlim=[-12, 12], ylim=[-10, 10])
    b ++ (
        slider("a", [[2, 8], [6, 8], [0, 3, 6]]),
        slider("b", [[2, 7], [6, 7], [0, 2, 6]]),
        slider("A", [[2, 6], [6, 6], [0, 3, 6]]),
        slider("B", [[2, 5], [6, 5], [0, 3, 6]]),
        slider("delta", [[2, 4], [6, 4], [0, 0, π]], name="&delta;"),
    )
    @jsf f1(t) = val(A)*sin(val(a)*t+val(delta))
    @jsf f2(t) = val(B)*sin(val(b)*t)
    b ++ plot(f1, f2, a=0, b=2π, strokecolor="#aa2233", strokewidth=3)
    s = str(b, preamble=false)
    @test isapproxstr(
        s,
        """(function(){
var brd=JXG.JSXGraph.initBoard("brd"
        ,
        {"boundingbox":[-12,10,12,-10],
        "axis":false,
        "showcopyright":false,
        "shownavigation":false});
var a=brd.create('slider', [[2,8],[6,8],[0,3,6]], {});
var b=brd.create('slider', [[2,7],[6,7],[0,2,6]], {});
var A=brd.create('slider', [[2,6],[6,6],[0,3,6]], {});
var B=brd.create('slider', [[2,5],[6,5],[0,3,6]], {});
var delta=brd.create('slider', [[2.0,4.0],[6.0,4.0],[0.0,0.0,3.141592653589793]], {"name":"&delta;"});
function f1(t){return (val(A)*sin(((val(a)*t)+val(delta))))};
function f2(t){return (val(B)*sin((val(b)*t)))};
brd.create(
        'curve',
        [function(t){return f1(t);}, function(t){return f2(t);},
         0, 6.283185307179586],
        {"strokecolor":"#aa2233",
        "strokewidth":3});})();
""",
    )
end
