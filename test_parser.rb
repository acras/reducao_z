#coding: utf-8
#

require "test-unit"
require "./parser"
require "bigdecimal"

class TestReductionZ < Test::Unit::TestCase

  def helper(text, redz)
    assert_equal redz, Parser.new.parse(text)
  end

  def test_id
    helper("05/03/2013 19:09:14 COO:017936\n", { :id => 17936 })
  end

  def test_data_movimento
    helper("MOVIMENTO DO DIA: 05/03/2013\n", { :data_movimento => Date.parse("05/03/2013") })
  end

  def test_cont_reducao_z
    helper("Contador de Reduções Z: 1330", { :cont_reducao_z => "1330" })
  end

  def test_cont_reinicio_operacao
    helper("Contador de Reinício de Operação: 004\n", { :cont_reinicio_operacao => "004" })
  end

  def test_cont_operacoes_nao_fiscais
    helper("Geral de Operação Não Fiscal: 005185\n", { :cont_operacoes_nao_fiscais => "005185" })
  end

  def test_cont_comp_deb_cred
    helper("Comprovante de Crédito ou Débito: 0004\n", { :cont_comp_deb_cred => "0004" })
  end

  def test_contadores_restantes
    text = <<-EOS.gsub(/^\s+/, "")
      Geral de Operação Não-Fiscal Cancelada: 0000
      Geral de Relatório Gerencial: 001817
      Contador de Cupom Fiscal: 009792
      Cupom Fiscal Cancelado: 0003
      Contador de Fita Detalhe: 000000
    EOS

    redz = {
      :cont_oper_nao_fiscais_canceladas =>  "0000",
      :cont_geral_rel_ger =>  "001817",
      :cont_cupom_fiscal =>  "009792",
      :cont_cupom_fiscal_cancelados =>  "0003",
      :cont_fita_detalhe_emitida =>  "000000"
    }


    helper(text, redz)
  end

  def test_totalizadores
    text = <<-EOS.gsub(/^\s+/, "")
      TOTALIZADOR GERAL: 1.533.200,46
      VENDA BRUTA DIÁRIA: 1.446,12
      CANCELAMENTO ICMS: 278,00
      DESCONTO ICMS: 15,78
      Total de ISSQN: 0,00
      CANCELAMENTO ISSQN: 0,00
    EOS

    redz = {
      :tot_geral => "1.533.200,46",
      # :venda_bruta => BigDecimal.new("1446.12"),
      :tot_cancelamentos_icms => "278,00",
      :tot_descontos_icms => "15,78",
      :tot_acrescimos_issqn => "0,00",
      :tot_cancelamentos_issqn => "0,00"
    }

    helper(text, redz)
  end

end
