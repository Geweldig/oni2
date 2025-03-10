/*
 * Diagnostics.rei
 *
 * This module is responsible for tracking the state of 'diagnostics'
 * (usually errors or warnings) that we render in the buffer view
 * or minimap.
 */

open EditorCoreTypes;
open Oni_Core;
open Exthost.Diagnostic;

module Diagnostic: {
  type t = {
    range: CharacterRange.t,
    message: string,
    severity: Severity.t,
    isUnused: bool,
    isDeprecated: bool,
    tags: list(Exthost.Diagnostic.Tag.t),
  };

  let create:
    (
      ~range: CharacterRange.t,
      ~message: string,
      ~severity: Severity.t,
      ~tags: list(Tag.t)
    ) =>
    t;

  /*
    [explode(buffer, diagnostic)] splits up a multi-line diagnostic into a diagnostic per-line
   */
  let explode: (Buffer.t, t) => list(t);

  let pp: (Format.formatter, t) => unit;
};

// MODEL

[@deriving show]
type msg;

type outmsg =
  | Nothing
  | OpenFile({
      filePath: string,
      position: EditorCoreTypes.CharacterPosition.t,
    })
  | PreviewFile({
      filePath: string,
      position: EditorCoreTypes.CharacterPosition.t,
    })
  | TogglePane({paneId: string});

module Msg: {
  let exthost: Exthost.Msg.Diagnostics.msg => msg;
  let diagnostics: (Uri.t, string, list(Diagnostic.t)) => msg;
  let clear: (~owner: string) => msg;
};

type model;

let initial: model;

// UPDATE

let update: (~previewEnabled: bool, msg, model) => (model, outmsg);

/*
 * [count(diagnostics)] gets the total count of all diagnostics across buffers
 */
let count: model => int;

let maxSeverity: list(Diagnostic.t) => Severity.t;

let moveMarkers:
  (~newBuffer: Oni_Core.Buffer.t, ~markerUpdate: MarkerUpdate.t, model) =>
  model;

/*
 * Get all diagnostics for a buffer
 */
let getDiagnostics: (model, Buffer.t) => list(Diagnostic.t);
let getDiagnosticsAtPosition:
  (model, Buffer.t, CharacterPosition.t) => list(Diagnostic.t);
let getDiagnosticsInRange:
  (model, Buffer.t, CharacterRange.t) => list(Diagnostic.t);
let getDiagnosticsMap: (model, Buffer.t) => IntMap.t(list(Diagnostic.t));

let getAllDiagnostics: model => list((Uri.t, Diagnostic.t));

module Contributions: {
  let commands: list(Command.t(msg));

  let keybindings: list(Feature_Input.Schema.keybinding);

  let pane: Feature_Pane.Schema.t(model, msg);
};

module Testing: {
  let change: (model, Uri.t, string, list(Diagnostic.t)) => model;
  let clear: (model, string) => model;
};
