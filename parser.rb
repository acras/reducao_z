#coding: utf-8

require "date"
require "bigdecimal"

REGEX = 0
TYPE = 1
MONEY_REGEX = /(\d+\.)*\d+,\d+/im
DATETIME_REGEX = /^\d+\/\d+\/\d+\s+\d+:\d+:\d+/im
REGEX_OPTIONS = Regexp::IGNORECASE | Regexp::MULTILINE

class Parser

  def initialize
    # parsing information for each field, organized like this:
    # :field_key => [/regex/, :data_type]
    @fields_spec = {
      :cont_ordem_operacao => [/coo:\d{6}/im, :string],
      :data_movimento => [/movimento\s+do\s+dia:\s+\d{2}\/\d{2}\/\d{4}/im, :date],
      :cont_reducao_z => [/contador\s+de\s+reduções\s+z:\s+\d+/im, :string],
      :cont_reinicio_operacao => [/contador\s+de\s+reinício\s+de\s+operação:\s+\d+/im, :string],
      :cont_geral_oper_nao_fiscais => [/geral\s+de\s+operação\s+não\s+fiscal:\s+\d+/im, :string],
      :cont_comp_deb_cred => [/comprovante\s+de\s+crédito\s+ou\s+débito:\s+\d+/im, :string],
      :cont_oper_nao_fiscais_canceladas => [/geral\s+de\s+operação\s+não-fiscal\s+cancelada: \d+/im, :string],
      :cont_geral_rel_ger => [/geral\s+de\s+relatório\s+gerencial:\s+\d+/im, :string],
      :cont_cupom_fiscal => [/contador\s+de\s+cupom\s+fiscal:\s+\d+/im, :string],
      :cont_cupom_fiscal_cancelados => [/cupom\s+fiscal\s+cancelado:\s+\d+/im, :string],
      :cont_fita_detalhe_emitida => [/contador\s+de\s+fita\s+detalhe:\s+\d+/im, :string],
      :cont_comp_deb_cred_nao_emitido => [/comprovante\s+não\s+emitido:\s+\d+/im, :string],
      :tot_geral => [Regexp.new("totalizador\s+geral:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :string_decimal],
      :venda_bruta => [Regexp.new("venda\s+bruta\s+diária:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :decimal],
      :tot_cancelamentos_icms => [Regexp.new("cancelamento\s+icms:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :string_decimal],
      :tot_descontos_icms => [Regexp.new("desconto\s+icms:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :string_decimal],
      :tot_acrescimos_issqn => [Regexp.new("acréscimo\s+iss:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :string_decimal],
      :tot_cancelamentos_issqn => [Regexp.new("cancelamento\s+issqn:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :string_decimal],
      :tot_acrescimos_icms => [Regexp.new("acréscimo\s+icms:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :string_decimal],
      :tot_isencao_icms => [Regexp.new("isento\s+icms:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :string_decimal],
      :tot_nao_incidencia_icms => [Regexp.new("não\s+incidência\s+icms:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :string_decimal],
      :tot_subst_trib_icms => [Regexp.new("substituição\s+tributária\s+icms:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :string_decimal],
      :tot_isencao_issqn => [Regexp.new("isento\s+issqn:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :string_decimal],
      :tot_nao_incidencia_issqn => [Regexp.new("não\s+incidência\s+issqn:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :string_decimal],
      # I had to use single quotes and concat here. For some weird reason, it doesn't work like the others.
      :tot_sangria => [Regexp.new('^\d+\s+sangria\s+:\s+\d+\s+'.concat(MONEY_REGEX.to_s), REGEX_OPTIONS), :string_decimal],
      :tot_suprimento => [Regexp.new('^\d+\s+suprimento\s+:\s+\d+\s+'.concat(MONEY_REGEX.to_s), REGEX_OPTIONS), :string_decimal],
      :tot_cancelamentos_nao_fiscais => [Regexp.new("canc\s+não-fisc:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :string_decimal],
      :tot_descontos_nao_fiscais => [Regexp.new("desc\s+não-fisc:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :string_decimal],
      :tot_acrescimos_nao_fiscais => [Regexp.new("acre\s+não-fisc:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :string_decimal],
      :tot_subst_trib_issqn => [Regexp.new("substituição\s+tributária\sISSQN:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :string_decimal]
    }
  end

  # converts a string to the given data type
  def fix_type(value, type)
    case type
    when :integer
      return value.to_i
    when :date
      return Date.parse(value).to_s
    when :string
      return value
    when :string_decimal
      # converting Brazilian money format to international format, as in:
      # 1.234,56 => 1234.56
      return ((BigDecimal.new(value.delete(".").gsub(",", ".")))*100).to_i.to_s
    when :decimal
      # converting Brazilian money format to international format, as in:
      # 1.234,56 => 1234.56
      return (BigDecimal.new(value.delete(".").gsub(",", "."))).to_f
    end
  end

  def parse(text, pos_id = 0, domain_id = 0)
    reducao_z = Hash.new

    # for each field specified in @fields_spec
    @fields_spec.each_key do |key|
      # matches the corresponding line using the specified regex
      line = @fields_spec[key][REGEX].match(text)

      if line != nil
        # extracts only the value from the matched line (after the ":")
        value = line.to_s.split(":")[1].strip

        # gets only the last value after the colon
        value = value.split(" ").last

        # converts to the specified data type
        reducao_z[key] = fix_type(value, @fields_spec[key][TYPE])
      end
    end

    data_hora_reducao = DATETIME_REGEX.match(text).to_s

    reducao_z[:data_hora_reducao] = DateTime.parse(data_hora_reducao).to_s unless data_hora_reducao.empty?

    reducao_z[:cont_comp_deb_cred_cancelados] = "0000"
    reducao_z[:cont_especificos_rel_ger] = "0" * 120
    reducao_z[:cont_operacaoes_nao_fiscais] = "0" * 120
    reducao_z[:tot_parc_nao_sujeitos_icms] = "0" * 392
    reducao_z[:tot_parc_nao_sujeitos_icms] = "0" * 392
    reducao_z[:tot_descontos_issqn] = "0" * 14
    reducao_z[:cont_fita_detalhe_emitida] = "000000"
    reducao_z[:cont_oper_nao_fiscais_canceladas] = "0000"
    reducao_z[:tot_nao_incidencia_icms] = "00000000000000"
    reducao_z[:tot_subst_trib_icms] = "00000000000000"
    reducao_z[:tot_isencao_issqn] = "00000000000000"
    reducao_z[:tot_nao_incidencia_issqn] = "00000000000000"
    reducao_z[:tot_subst_trib_issqn] = "00000000000000"
    reducao_z[:tot_acrescimos_issqn] = "00000000000000"
    reducao_z[:tot_cancelamentos_nao_fiscais] = "00000000000000"
    reducao_z[:tot_descontos_nao_fiscais] = "00000000000000"
    reducao_z[:tot_acrescimos_nao_fiscais] = "00000000000000"
    reducao_z[:modo] = "00"
    reducao_z[:pos_id] = pos_id
    reducao_z[:domain_id] = domain_id

    reducao_z
  end
end
