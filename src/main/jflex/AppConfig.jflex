import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.nio.charset.Charset;

enum Classe {
    cId,
    cInt,
    cReal,
    cPalRes,
    cDoisPontos,
    cAtribuicao,
    cMais,
    cMenos,
    cDivisao,
    cMultiplicacao,
    cMaior,
    cMenor,
    cMaiorIgual,
    cMenorIgual,
    cDiferente,
    cIgual,
    cVirgula,
    cPontoVirgula,
    cPonto,
    cParEsq,
    cParDir,
    cString,
    cEOF
}

class Valor {
    private int valorInteiro;
    private double valorDecimal;
    private String valorIdentificador;

    public Valor() {}
    public Valor(double valorDecimal) { this.valorDecimal = valorDecimal; }
    public Valor(int valorInteiro) { this.valorInteiro = valorInteiro; }
    public Valor(String valorIdentificador) { this.valorIdentificador = valorIdentificador; }

    public int getValorInteiro() { return valorInteiro; }
    public void setValorInteiro(int valorInteiro) { this.valorInteiro = valorInteiro; }

    public double getValorDecimal() { return valorDecimal; }
    public void setValorDecimal(double valorDecimal) { this.valorDecimal = valorDecimal; }

    public String getValorIdentificador() { return valorIdentificador; }
    public void setValorIdentificador(String valorIdentificador) { this.valorIdentificador = valorIdentificador; }

    @Override
    public String toString() {
        return "Valor {" +
                "valorInteiro: " + valorInteiro +
                ", valorDecimal: " + valorDecimal +
                ", valorIdentificador: '" + valorIdentificador + '\'' +
                '}';
    }
}

class Token {
    private Classe classe;
    private Valor valor;
    private int linha;
    private int coluna;

    public Token(Classe classe, int linha, int coluna) {
        this.classe = classe;
        this.linha = linha;
        this.coluna = coluna;
    }

    public Token(Classe classe, Valor valor, int linha, int coluna) {
        this.classe = classe;
        this.valor = valor;
        this.linha = linha;
        this.coluna = coluna;
    }

    public Classe getClasse() { return classe; }
    public void setClasse(Classe classe) { this.classe = classe; }

    public Valor getValor() { return valor; }
    public void setValor(Valor valor) { this.valor = valor; }

    public int getLinha() { return linha; }
    public void setLinha(int linha) { this.linha = linha; }

    public int getColuna() { return coluna; }
    public void setColuna(int coluna) { this.coluna = coluna; }

    @Override
    public String toString() {
        return "Token {" +
                "classe: " + classe +
                ", valor: " + valor +
                ", linha: " + linha +
                ", coluna: " + coluna +
                '}';
    }
}

%%

%class Lexico
%type Token
%unicode
%column
%line

/* Regras JFlex ------------------------------- */
NUMEROS = [0-9]
LETRAS = [A-Za-z]
INT = 0 | [1-9]{NUMEROS}*
IDENTIFICADOR = {LETRAS}({LETRAS}|{NUMEROS})*
STRING = \"[^\"]*\"
REAL = {INT}\.{NUMEROS}+
PALAVRAS_RESERVADAS = "and"|"array"|"begin"|"case"|"const"|"div"|"do"|"downto"|"else"|"end"|"file"|"for"|"function"|"goto"|"if"|"in"|"label"|"mod"|"nil"|"not"|"of"|"or"|"packed"|"procedure"|"program"|"record"|"repeat"|"set"|"then"|"to"|"type"|"until"|"var"|"while"|"with"
OPERADORES = ":="|">="|"<="|"<>"|"="|":"|"+"|"-"|"/"|"*"|">"|"<"|","|";"|"."
PARENTESES = "\(" | "\)"
EOF = [\r\n]+
ESPACO = {EOF} | [ \t\f]
/* FIM Regras JFlex ------------------------------- */

%{
public static void main(String[] args) {
        if (args.length == 0) {
            System.out.println("Usage : java Lexico [ --encoding <name> ] <inputfile(s)>");
        } else {
            int firstFilePos = 0;
            String encodingName = "UTF-8";

            if (args[0].equals("--encoding")) {
                firstFilePos = 2;
                encodingName = args[1];
                try {
                    Charset.forName(encodingName);
                } catch (Exception e) {
                    System.out.println("Invalid encoding '" + encodingName + "'");
                    return;
                }
            }

            for (int i = firstFilePos; i < args.length; i++) {
                try {
                    FileInputStream fileInputStream = new FileInputStream(args[i]);
                    Reader reader = new InputStreamReader(fileInputStream, encodingName);
                    Token token;
                    Lexico scanner = new Lexico(reader);
                    while (!scanner.zzAtEOF) {
                        token = scanner.yylex();
                        if(token != null) System.out.println(token.toString());
                    }
                    System.out.println("Análise Concluída!");
                } catch (Exception e) {
                    System.out.println(e);
                }
            }
        }
    }
%}

%%

/* AÇÕES JFLEX ------------------------------ */
{ESPACO}     {}
{INT}                 { return new Token(Classe.cInt, new Valor(Integer.parseInt(yytext())), yyline + 1, yycolumn + 1); }
{PALAVRAS_RESERVADAS} { return new Token(Classe.cPalRes, new Valor(yytext()), yyline + 1, yycolumn + 1); }
{IDENTIFICADOR}       { return new Token(Classe.cId, new Valor(yytext()), yyline + 1, yycolumn + 1); }
{STRING}              { return new Token(Classe.cString, new Valor(yytext()), yyline + 1, yycolumn + 1); }
{REAL}                { return new Token(Classe.cReal, new Valor(Double.parseDouble(yytext())), yyline + 1, yycolumn + 1); }
{OPERADORES} { /* ":="|">="|"<="|"<>"|"="|":"|"+"|"-"|"/"|"*"|">"|"<"|","|";"|"." */
    switch (yytext()) {
        case ":=": return new Token(Classe.cAtribuicao, new Valor(yytext()), yyline + 1, yycolumn + 1);
        case ">=": return new Token(Classe.cMaiorIgual, new Valor(yytext()), yyline + 1, yycolumn + 1);
        case "<=": return new Token(Classe.cMenorIgual, new Valor(yytext()), yyline + 1, yycolumn + 1);
        case "<>": return new Token(Classe.cDiferente, new Valor(yytext()), yyline + 1, yycolumn + 1);
        case "=":  return new Token(Classe.cIgual, new Valor(yytext()), yyline + 1, yycolumn + 1);
        case "+":  return new Token(Classe.cMais, new Valor(yytext()), yyline + 1, yycolumn + 1);
        case ":":  return new Token(Classe.cDoisPontos, new Valor(yytext()), yyline + 1, yycolumn + 1);
        case "-":  return new Token(Classe.cMenos, new Valor(yytext()), yyline + 1, yycolumn + 1);
        case "/":  return new Token(Classe.cDivisao, new Valor(yytext()), yyline + 1, yycolumn + 1);
        case "*":  return new Token(Classe.cMultiplicacao, new Valor(yytext()), yyline + 1, yycolumn + 1);
        case ">":  return new Token(Classe.cMaior, new Valor(yytext()), yyline + 1, yycolumn + 1);
        case "<":  return new Token(Classe.cMenor, new Valor(yytext()), yyline + 1, yycolumn + 1);
        case ",":  return new Token(Classe.cVirgula, new Valor(yytext()), yyline + 1, yycolumn + 1);
        case ";":  return new Token(Classe.cPontoVirgula, new Valor(yytext()), yyline + 1, yycolumn + 1);
        case ".":  return new Token(Classe.cPonto, new Valor(yytext()), yyline + 1, yycolumn + 1);
    }
}
{PARENTESES} {
    switch (yytext()) {
        case "(": return new Token(Classe.cParEsq, new Valor(yytext()), yyline + 1, yycolumn + 1);
        case ")": return new Token(Classe.cParDir, new Valor(yytext()), yyline + 1, yycolumn + 1);
    }
}
/* FIM AÇÕES JFLEX ------------------------------ */