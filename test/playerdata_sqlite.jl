module PDSQLiteTests

using Test
import ..AKCalc

@testset "Basic PlayerData entry" begin
  source = AKCalc.PDSQLite()
  base = AKCalc.OperatorBase("test_op_1", "Test Operator", 1)
  gd = AKCalc.GDMem()
  append!(gd, [base])
  op1 = AKCalc.Operator(base)
  @test append!(source, [op1]) == nothing
  @test AKCalc.operators(source, gd) == [op1]
end

end

