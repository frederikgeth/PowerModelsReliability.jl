using Documenter, PowerModelsReliability

makedocs(
    modules = [PowerModelsReliability],
    format = :html,
    sitename = "PowerModelsReliability",
    authors = "Frederik Geth, Hakan Ergun",
    pages = [
        "Home" => "index.md",
        "Manual" => [
            "Getting Started" => "quickguide.md",
            "Results" => "result-data.md",
        ],
        "Library" => [
            "Network Formulations" => "formulations.md",
            "Problem Specifications" => "specifications.md",
            "Modeling Components" => [
                "Objective" => "objective.md",
                "Variables" => "variables.md",
                "Constraints" => "constraints.md"
            ],
            "File IO" => "parser.md"
        ],
    ]
)
