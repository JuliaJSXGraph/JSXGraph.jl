# Point
begin
    b = board("brd"; xlim=[0, 1], ylim=[0, 1])
    b ++ slider("s", [[0.1, 0.1], [0.6, 0.1], [0, 0.2, 1]])
    b ++ @jsf m() = val(b)
    b ++ (
        point(0.5, 0.5; strokecolor="blue", fillcolor="blue", name="hello"),
        point(0.7, m; strokecolor="blue"),
    )
    s = str(b; preamble=false)
    @test isapproxstr(
        s,
        """(function(){
function m(){return val(b)};
var brd=JXG.JSXGraph.initBoard("brd",
        {"boundingbox":[0,1,1,0],
        "axis":false,
        "showcopyright":false,
        "shownavigation":false});
var s=brd.create(
        'slider',
        [[0.1,0.1],[0.6,0.1],[0.0,0.2,1.0]], {});
brd.create(
        'point',
        [0.5, 0.5],
        {"strokecolor":"blue",
        "fillcolor":"blue",
        "name":"hello"});
brd.create(
        'point',
        [0.7, function(t){return m(t);}],
        {"strokecolor":"blue"});})();
""",
    )
end
