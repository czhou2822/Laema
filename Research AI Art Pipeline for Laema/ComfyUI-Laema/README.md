# Generate Laema artwork locally

1. Double-click **Start-Laema-Art.cmd** in the checkout root (or **START-LAEMA.cmd** here). Wait for the local ComfyUI page to open.
2. Open **Laema - Qwen Reference Art** from the **Apps** sidebar (or the Workflows sidebar in Graph mode). It opens in App mode with a simple form.
3. Edit **Your prompt** on the right. Describe the pose, expression, setting, lighting or kind of picture you want. The reference images and character guide are already connected behind the form.
4. Click **Run**. The saved Laema Open and hammer references are already connected. A full-size image took about five and a half minutes in the earlier RTX4090 comparison.
5. Find the numbered PNG in **output/Laema/**, or double-click **OPEN-OUTPUT.cmd**.
6. Double-click **STOP-LAEMA.cmd** when finished to stop the model server and release its GPU memory. This also stops unfinished jobs. Closing the browser alone does not stop it.

The local address is **http://127.0.0.1:8188**. No OpenAI account, API key, Codex chat, image-generation credits or subscription tokens are required to run this workflow yourself. The downloaded models run on this computer. The launcher enables offline mode and disables paid partner/API nodes and custom nodes.

The workflow uses the same installed Qwen Image Edit2511 FP8 model as the executed comparison. The separate character guide is combined with your prompt automatically. It asks the model to retain the current reference identity; you can explicitly request changes. A reference guides the model and does not guarantee perfect identity, fingers or equipment.

Defaults:1024x1536,40steps,CFG4,Euler/simple. The seed randomizes after a run for new variations. Change seed behavior to fixed when you want repeatable settings. Start with batch size1 on this24GB GPU. Output PNGs preserve the workflow/prompt metadata so you can drag an output image back into ComfyUI to recover its recipe.

The Apps library now includes **Qwen**, **FLUX2 Base**, **FLUX2 Fast**, **LongCat**, and **Z-Image Text Only**. Choose an app to change model families; its sampler/encoder settings are configured for that family. The Qwen app keeps both original setup references; the other reference apps use the saved combined Laema hero reference. Z-Image uses a written character guide and no image reference. These are experimental choices, not a ranked or accepted production method.

The model survey's full-size results took approximately219–223seconds for Qwen,31–41seconds for FLUX Base,5–15seconds for FLUX Fast,122–142seconds for LongCat, and15–36seconds for Z-Image. These are observed request/save durations with different native sampling settings and caching conditions. See [the ten-image comparison](../local-trials/2026-10-23-local-model-survey-v01/REVIEW.md).

Width and Height stay fixed between runs. Use multiples of16. Only the seed randomizes by default. **Number of runs** queues variations without increasing the per-image latent batch size. Use **Ctrl+S** to save your prompt/settings in the selected app; the launcher preserves saved user copies.

Your saved, editable workflows live in **user/default/workflows/**. The **workflows/** folder holds the supplied starter templates. Machine-specific state and logs are kept separate; the saved workflow JSON files remain visible to project version control.

The local machine's cache path lives in ignored **config.local.json**. No model weights are copied into this repository. On another machine, set **LAEMA_AI_CACHE** or update that local configuration to point at the installed cache. The starter preserves saved workflows and does not replace existing output images.

The source references remain unchanged. Laema Open is one approved outfit alternative; the saved hammer is a concept reference, not a final production weapon choice. Generated pictures stay separate from production assets. The Art comparison's initial user feedback reported little visible difference between Qwen and built-in generation; it did not accept a production method.

Native ComfyUI GUI workflow JSON and its API equivalent are in **workflows/**. Official reference: [ComfyUI workflows](https://docs.comfy.org/interface/features/template).

The App mode setup was built and saved through the actual ComfyUI interface. A prompt was entered in the form and Run produced **output/Laema/Qwen_00001_.png** at1024x1536. The output is an operational test, not approved artwork; the hammer construction is not fully preserved. [Interface screenshot](evidence/app-ready.jpg) and [execution history](evidence/gui-history.json) record this boundary.

A second actual App-mode test changed the FLUX Fast prompt and canvas dimensions through the form. It produced **output/Laema/flux-fast_00001_.png** at512x768. Both the output latent and model scheduler received the same selected dimensions. This operational test is separate from the matched art comparisons.

The actual root Start/Stop launchers were then executed. The old endpoint stopped, a new server process started, and all six saved workflow files—including five Apps—retained identical hashes. App mode and full-size settings were checked after restart. [Final model chooser](evidence/apps-ready.jpg), [restart record](evidence/restart-check.json), and [verification](evidence/verification.json) preserve the evidence. Output PNGs remain on disk across restarts; the current-session results pane may start empty.
