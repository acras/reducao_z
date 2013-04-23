require "test-unit"
require "./parser"

class TestReductionZ < Test::Unit::TestCase

  def setup
    @text << "------------------------------------------------\n"
    @text << "05/03/2013 19:09:14 COO:017936\n"
    @text << "------------------------------------------------\n"
    @text << "REDUÇÃO Z\n"
    @text << "MOVIMENTO DO DIA: 05/03/2013\n"
    @text << "-------CONTADORES-------\n"
    @text << "Contador de Reduções Z: 1330\n"
    @text << "Contador de Reinício de Operação: 004\n"
    @text << "Geral de Operação Não Fiscal: 005185\n"
    @text << "Comprovante de Crédito ou Débito: 0004\n"
    @text << "Geral de Operação Não-Fiscal Cancelada: 0000\n"
    @text << "Geral de Relatório Gerencial: 001817\n"
    @text << "Contador de Cupom Fiscal: 009792\n"
    @text << "Cupom Fiscal Cancelado: 0003\n"
    @text << "Contador de Fita Detalhe: 000000\n"
    @text << "-TOTALIZADORES FISCAIS--\n"
    @text << "TOTALIZADOR GERAL: 1.533.200,46\n"
    @text << "VENDA BRUTA DIÁRIA: 1.446,00\n"
    @text << "CANCELAMENTO ICMS: 278,00\n"
    @text << "DESCONTO ICMS: 15,78\n"
    @text << "Total de ISSQN: 0,00\n"
    @text << "CANCELAMENTO ISSQN: 0,00\n"
    @text << "------------------\n"
    @text << "VENDA LÍQUIDA: 1.152,22\n"
    @text << "ACRÉSCIMO ICMS: 0,00\n"
    @text << "ACRÉSCIMO ISS: 0,00\n"
    @text << "----------ICMS----------\n"
    @text << "Totalizador Base Cálculo( R$) Imposto( R$)\n"
    @text << "T07,00% 0,00 0,00\n"
    @text << "T12,00% 0,00 0,00\n"
    @text << "T25,00% 0,00 0,00\n"
    @text << "T17,00% 487,50 82,87\n"
    @text << "------------------\n"
    @text << "Total ICMS: 487,50 82,87\n"
    @text << "---------ISSQN----------\n"
    @text << "Totalizador Base Cálculo( R$) Imposto( R$)\n"
    @text << "------------------\n"
    @text << "Total ISSQN: 0,00 0,00\n"
    @text << "-----Não Tributados-----\n"
    @text << "Totalizador Valor Acumulado( R$)\n"
    @text << "Substituição Tributária ICMS: 0,00\n"
    @text << "Isento ICMS: 664,72\n"
    @text << "Não Incidência ICMS: 0,00\n"
    @text << "Substituição Tributária ISSQN: 0,00\n"
    @text << "Isento ISSQN: 0,00\n"
    @text << "Não Incidência ISSQN: 0,00\n"
    @text << "-----------TOTALIZADORES NÃO FISCAIS------------\n"
    @text << "CANC NÃO-FISC: 0,00\n"
    @text << "DESC NÃO-FISC: 0,00\n"
    @text << "ACRE NÃO-FISC: 0,00\n"
    @text << "Nº Operação CON Valor Acumulado( R$)\n"
    @text << "29 Sangria : 0001 50,00\n"
    @text << "30 Suprimento : 0001 50,00\n"
    @text << "------------------\n"
    @text << "Total Operações Não-Fiscais R$ 100,00\n"
    @text << "--RELATÓRIO GERENCIAL---\n"
    @text << "Nº Relatório CER\n"
    @text << "01 Relatório Geral 0005\n"
    @text << "---MEIOS DE PAGAMENTO---\n"
    @text << "No. Meio Pagamento TEF Valor Acumulado ( R$)\n"
    @text << "01 Dinheiro N 343,00\n"
    @text << "02 cartão S 436,35\n"
    @text << "03 Cheque S 404,00\n"
    @text << "04 Devoluçäes S 65,00\n"
    @text << "05 Saldo anterior S 0,00\n"
    @text << "TROCO 46,13\n"
    @text << "------------------------------------------------\n"
    @text << "Comprovante Não Emitido: 0002\n"
    @text << "Tempo Emitindo Doc. Fiscal: 00:18:20\n"
    @text << "Tempo Operacional: 19:09:14\n"
    @text << "MFD: 8751061142206\n"
    @text << "Número de Reduções Restantes: 0712\n"
    @text << "------------------------------------------------\n"
    @text << "BEMATECH MP-2000 TH FI ECF-IF\n"
    @text << "ECF:001 LJ:0032 VERSÃO:01.03.02\n"
    @text << "FAB:BE0306SC95531101930 05/03/2013 19:09:43\n"
    @text << "QQQQQQQQQWYRREQQTU BR\n"
    @text << "------------------------------------------------\n"

    @parser = Parser.new
  end

  # def test_parse
  #   @parser.parse(@text)

  #   redz = {
  #     :id => 17936,
  #     :data_movimento => Date.parse("05/03/2013"),
  #     :cont_reinicio_operacao => "004",
  #     :cont_reducao_z => "1330",
  #     :cont_operacoes_nao_fiscais => "005185",
  #     :cont_comp_deb_cred => "0004"
  #   }

  #   assert_equal redz, @parser.reducao_z
  # end

  def test_cont_reinicio_operacao
    text = "Contador de Reinício de Operação: 004\n"

    redz = {
      :cont_reinicio_operacao => "004"
    }

    @parser.parse(text)

    assert_equal redz, @parser.reducao_z
  end

  def test_cont_operacoes_nao_fiscais
    text = "Geral de Operação Não Fiscal: 005185"

    redz = {
      :cont_operacoes_nao_fiscais => "005185"
    }

    @parser.parse(text)

    assert_equal redz, @parser.reducao_z
  end

  def test_cont_comp_deb_cred
    text = "Comprovante de Crédito ou Débito: 0004"

    redz = {
      :cont_comp_deb_cred => "0004"
    }

    @parser.parse(text)

    assert_equal redz, @parser.reducao_z 
  end

end
