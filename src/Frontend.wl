BeginPackage["CoffeeLiqueur`Extensions`EvalAllButton`", {
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`",
    "JerryI`WLX`Importer`",
    "JerryI`WLX`WebUI`"
}]

Needs["CoffeeLiqueur`Notebook`AppExtensions`" -> "AppExtensions`"];

Needs["CoffeeLiqueur`Notebook`Cells`" -> "cell`"];
Needs["CoffeeLiqueur`Notebook`" -> "nb`"];

Begin["`Private`"]

rootFolder = $InputFileName // DirectoryName // ParentDirectory;

(* load settings methods (OPTIONAL) *)
{loadSettings, storeSettings}        = ImportComponent["Frontend/Settings.wl"];


buttonTemplate = ImportComponent[FileNameJoin[{rootFolder, "templates", "Button.wlx"}] ];
AppExtensions`TemplateInjection["AppNotebookTopBar"] = buttonTemplate[##, "HandlerFunction" -> processRequest]&;

findNotebook[messagesPort_] := EventFire[messagesPort, "NotebookQ", True] /. {{___, n_nb`NotebookObj, ___} :> n};


processRequest[globalControls_String, modals_String, messager_String, client_] := With[{
    notebookOnline = findNotebook[globalControls]
},
    If[!MatchQ[notebookOnline, _nb`NotebookObj], 
        EvetFire[messager, "Warning", "No active notebooks"];
        Return[];
    ];

    Echo["Processing!"];

    With[{
        inputCells = Select[notebookOnline["Cells"], cell`InputCellQ]
    },
    
        (* If you don't want to handle Kernel requests and prepare the rest -> use Notebooks public API *)
        runNext[inputCells, Function[cell, EventFire[globalControls, "NotebookCellEvaluate", cell] ] ];
    ]
]

runNext[l_List, f_] := With[{rest = Drop[l, 1]}, 
    Then[f[l // First], Function[Null,
        runNext[rest, f]
    ] ]
] /; Length[l] > 0

runNext[_List, f_] := Echo["Done!"];

End[]
EndPackage[]