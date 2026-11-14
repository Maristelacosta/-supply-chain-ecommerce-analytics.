let
    CaminhoDados = "C:\\Projetos\\Supply-chain-ecommerce-analytics.\\data",
    Arquivo = Csv.Document(
        File.Contents(CaminhoDados & "\\fornecedores.csv"),
        [Delimiter=";", Encoding=65001, QuoteStyle=QuoteStyle.Csv]
    ),
    Cabecalhos = Table.PromoteHeaders(Arquivo, [PromoteAllScalars=true]),
    Tipos = Table.TransformColumnTypes(
        Cabecalhos,
        {
            {"id_fornecedor", Int64.Type},
            {"nome_fornecedor", type text},
            {"lead_time_acordado_dias", Int64.Type}
        },
        "pt-BR"
    )
in
    Tipos
