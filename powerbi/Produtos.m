let
    CaminhoDados = "C:\\Projetos\\Supply-chain-ecommerce-analytics.\\data",
    Arquivo = Csv.Document(
        File.Contents(CaminhoDados & "\\produtos.csv"),
        [Delimiter=";", Encoding=65001, QuoteStyle=QuoteStyle.Csv]
    ),
    Cabecalhos = Table.PromoteHeaders(Arquivo, [PromoteAllScalars=true]),
    Tipos = Table.TransformColumnTypes(
        Cabecalhos,
        {
            {"id_produto", Int64.Type},
            {"nome_produto", type text},
            {"estoque_atual", Int64.Type},
            {"estoque_minimo", Int64.Type},
            {"id_fornecedor", Int64.Type}
        },
        "pt-BR"
    ),
    RiscoRuptura = Table.AddColumn(
        Tipos,
        "Risco de Ruptura",
        each [estoque_atual] < [estoque_minimo],
        type logical
    )
in
    RiscoRuptura
