let
    CaminhoDados = "C:\\Projetos\\Supply-chain-ecommerce-analytics.\\data",
    Arquivo = Csv.Document(
        File.Contents(CaminhoDados & "\\pedidos.csv"),
        [Delimiter=";", Encoding=65001, QuoteStyle=QuoteStyle.Csv]
    ),
    Cabecalhos = Table.PromoteHeaders(Arquivo, [PromoteAllScalars=true]),
    TiposConhecidos = Table.TransformColumnTypes(
        Cabecalhos,
        {
            {"data_entrega_real", type date},
            {"data_prevista_entrega", type date},
            {"qtd_entregue", Int64.Type},
            {"qtd_solicitada", Int64.Type},
            {"valor_frete", Currency.Type},
            {"transportadora", type text}
        },
        "pt-BR"
    ),
    OnTime = Table.AddColumn(
        TiposConhecidos,
        "On-Time",
        each [data_entrega_real] <= [data_prevista_entrega],
        type logical
    ),
    InFull = Table.AddColumn(
        OnTime,
        "In-Full",
        each [qtd_entregue] = [qtd_solicitada],
        type logical
    ),
    OTIF = Table.AddColumn(
        InFull,
        "OTIF",
        each [On-Time] and [In-Full],
        type logical
    ),
    DiasAtraso = Table.AddColumn(
        OTIF,
        "Dias de Atraso",
        each if [data_entrega_real] > [data_prevista_entrega]
            then Duration.Days([data_entrega_real] - [data_prevista_entrega])
            else 0,
        Int64.Type
    )
in
    DiasAtraso
