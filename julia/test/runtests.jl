using Test
using PRCoords

@testset "vectors" begin
    p = Coords(20.235733, 115.254019)
    w = wgs_gcj(p)
    @test abs(w.lat - 20.233449500423102) < 1e-12
    @test abs(w.lon - 115.25861410396281) < 1e-12
    g = wgs_gcj(Coords(35, 105))
    @test abs(g.lat - 34.99909863223526) < 1e-12
    @test abs(g.lon - 105.00328624145706) < 1e-12
    @test in_china(Coords(35, 105))
    @test !in_china(Coords(48.8566, 2.3522))
    @test distance(Coords(35, 105), Coords(35, 105)) == 0
    @test abs(wgs_gcj(gcj_wgs(g)) - g) < 1e-4
end
