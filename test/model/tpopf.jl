@testset "test ac polar tfopf" begin
    @testset "5-bus tf case" begin
        result = run_ac_tfopf("../test/data/case5_tf.m", ipopt_solver)

        @test result["status"] == :LocalOptimal
        @test isapprox(result["objective"], 15155.17; atol = 1e0)
        @test isapprox(result["branch"]["4"]["shiftf"], -0.06455903636089573; atol = 1e-3)
        @test isapprox(result["branch"]["5"]["tapf"], 1.015432875398519; atol = 1e-3)
    end
end

@testset "test dc tfopf" begin
    @testset "5-bus tf case" begin
        result = run_dc_tfopf("../test/data/case5_tf.m", ipopt_solver)

        @test result["status"] == :LocalOptimal
        @test isapprox(result["objective"], 14979.73; atol = 1e0)
        @test isapprox(result["branch"]["4"]["shiftf"], -0.06455903636089573; atol = 1e-3)
    end
end

#TODO implement the rest of the unit tests
