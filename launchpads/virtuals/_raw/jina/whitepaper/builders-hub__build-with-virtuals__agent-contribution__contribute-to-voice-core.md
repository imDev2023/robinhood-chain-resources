> For the complete documentation index, see [llms.txt](https://whitepaper.virtuals.io/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://whitepaper.virtuals.io/builders-hub/build-with-virtuals/agent-contribution/contribute-to-voice-core.md).

# Contribute to Voice Core

## Contribute to Voice Core&#x20;

Contributors can enhance the Voice Core in two ways:

* Improve the TTS model
* Contribute new Voice Data

{% hint style="success" %}
No contribution to the STT model is needed, as it currently utilizes Azure services. The accuracy is already optimal, and no further enhancements are required.
{% endhint %}

### Improvement on the TTS model

All files related to the model **must** be submitted. There are several service providers supported by the ecosystem. Below is a list of them and their requirements:

{% tabs %}
{% tab title="GPT-Sovits" %}

* **sovits.pth**: This is your main model file. Ensure it's named "sovits.pth" as specified.
* **reference1.wav**: Reference audio file in .wav format. Make sure the name of the file matches the reference in the "config.json" file.
* **gpt.ckpt**: The checkpoint file for the model. Confirm it is named "gpt.ckpt".
* **config.json**: The configuration file for your model. It must be named "config.json".

Below is the structure for a sample folder submission of a complete model.&#x20;

```
AudioModelSubmission/
├── sovits.pth                # The main model file
├── reference1.wav            # Reference audio file (name as per config.json)     
├── gpt.ckpt                  # Checkpoint file for the model
└── config.json               # Configuration file for the model

```

A sample config.json file is as below.&#x20;

```json
{
    "refFile": "Olyn.wav",
    "refText": "yet still, I stand, a testiment to the resilience of human spirit"
}

```

{% endtab %}

{% tab title="XTTS" %}

* **model.pth**: This is the main model file. It must be named "model.pth".
* **audio.wav**: This is the reference audio file in .wav format. Ensure it is named "audio.wav".
* **vocab.json**: This JSON file contains the vocabulary that the TTS system uses. It must be named "vocab.json".
* **config.json**: This is the configuration file for your model. It must be named "config.json".

Below is the structure for a sample folder submission of a complete model.&#x20;

```
AudioModelProject/
├── model.pth                # The main model file
├── audio.wav                # Reference audio file
├── vocab.json               # Vocabulary file for the TTS system
└── config.json              # Configuration file for the model
```

A sample config.json file is as below.&#x20;

{% code overflow="wrap" lineNumbers="true" %}

````json
```json
{
    "output_path": "output",
    "logger_uri": null,
    "run_name": "run",
    "project_name": null,
    "run_description": "\ud83d\udc38Coqui trainer run.",
    "print_step": 25,
    "plot_step": 100,
    "model_param_stats": false,
    "wandb_entity": null,
    "dashboard_logger": "tensorboard",
    "save_on_interrupt": true,
    "log_model_step": null,
    "save_step": 10000,
    "save_n_checkpoints": 5,
    "save_checkpoints": true,
    "save_all_best": false,
    "save_best_after": 10000,
    "target_loss": null,
    "print_eval": false,
    "test_delay_epochs": 0,
    "run_eval": true,
    "run_eval_steps": null,
    "distributed_backend": "nccl",
    "distributed_url": "tcp://localhost:54321",
    "mixed_precision": false,
    "precision": "fp16",
    "epochs": 1000,
    "batch_size": 32,
    "eval_batch_size": 16,
    "grad_clip": 0.0,
    "scheduler_after_epoch": true,
    "lr": 0.001,
    "optimizer": "radam",
    "optimizer_params": null,
    "lr_scheduler": null,
    "lr_scheduler_params": {},
    "use_grad_scaler": false,
    "allow_tf32": false,
    "cudnn_enable": true,
    "cudnn_deterministic": false,
    "cudnn_benchmark": false,
    "training_seed": 54321,
    "model": "xtts",
    "num_loader_workers": 0,
    "num_eval_loader_workers": 0,
    "use_noise_augment": false,
    "audio": {
        "sample_rate": 22050,
        "output_sample_rate": 24000
    },
    "use_phonemes": false,
    "phonemizer": null,
    "phoneme_language": null,
    "compute_input_seq_cache": false,
    "text_cleaner": null,
    "enable_eos_bos_chars": false,
    "test_sentences_file": "",
    "phoneme_cache_path": null,
    "characters": null,
    "add_blank": false,
    "batch_group_size": 0,
    "loss_masking": null,
    "min_audio_len": 1,
    "max_audio_len": Infinity,
    "min_text_len": 1,
    "max_text_len": Infinity,
    "compute_f0": false,
    "compute_energy": false,
    "compute_linear_spec": false,
    "precompute_num_workers": 0,
    "start_by_longest": false,
    "shuffle": false,
    "drop_last": false,
    "datasets": [
        {
            "formatter": "",
            "dataset_name": "",
            "path": "",
            "meta_file_train": "",
            "ignored_speakers": null,
            "language": "",
            "phonemizer": "",
            "meta_file_val": "",
            "meta_file_attn_mask": ""
        }
    ],
    "test_sentences": [],
    "eval_split_max_size": null,
    "eval_split_size": 0.01,
    "use_speaker_weighted_sampler": false,
    "speaker_weighted_sampler_alpha": 1.0,
    "use_language_weighted_sampler": false,
    "language_weighted_sampler_alpha": 1.0,
    "use_length_weighted_sampler": false,
    "length_weighted_sampler_alpha": 1.0,
    "model_args": {
        "gpt_batch_size": 1,
        "enable_redaction": false,
        "kv_cache": true,
        "gpt_checkpoint": null,
        "clvp_checkpoint": null,
        "decoder_checkpoint": null,
        "num_chars": 255,
        "tokenizer_file": "",
        "gpt_max_audio_tokens": 605,
        "gpt_max_text_tokens": 402,
        "gpt_max_prompt_tokens": 70,
        "gpt_layers": 30,
        "gpt_n_model_channels": 1024,
        "gpt_n_heads": 16,
        "gpt_number_text_tokens": 6681,
        "gpt_start_text_token": null,
        "gpt_stop_text_token": null,
        "gpt_num_audio_tokens": 1026,
        "gpt_start_audio_token": 1024,
        "gpt_stop_audio_token": 1025,
        "gpt_code_stride_len": 1024,
        "gpt_use_masking_gt_prompt_approach": true,
        "gpt_use_perceiver_resampler": true,
        "input_sample_rate": 22050,
        "output_sample_rate": 24000,
        "output_hop_length": 256,
        "decoder_input_dim": 1024,
        "d_vector_dim": 512,
        "cond_d_vector_in_each_upsampling_layer": true,
        "duration_const": 102400
    },
    "model_dir": null,
    "languages": [
        "en",
        "es",
        "fr",
        "de",
        "it",
        "pt",
        "pl",
        "tr",
        "ru",
        "nl",
        "cs",
        "ar",
        "zh-cn",
        "hu",
        "ko",
        "ja",
        "hi"
    ],
    "temperature": 0.75,
    "length_penalty": 1.0,
    "repetition_penalty": 5.0,
    "top_k": 50,
    "top_p": 0.85,
    "num_gpt_outputs": 1,
    "gpt_cond_len": 30,
    "gpt_cond_chunk_len": 4,
    "max_ref_len": 30,
    "sound_norm_refs": false
}
```
````

{% endcode %}
{% endtab %}
{% endtabs %}

To submit a Voice Model, select Voice Core

<figure><img src="/files/ApRNASZPFqGqQZAhv0tr" alt=""><figcaption></figcaption></figure>

Then "I got a Voice Model" and upload the model file following the guidelines provided above.

<figure><img src="/files/qWTCW7EE07Xm2BDfuggv" alt=""><figcaption></figcaption></figure>

### New Voice Data Contribution

* Voice data submitted must be legally acquired with the right to share.
* Voice data acquired must be acquired from authentic sources.&#x20;
* Voice data, data should be free from background noise and only voices to be trained are kept in the audio.&#x20;
* Voice data must be produced in format of .wav.&#x20;


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/builders-hub/build-with-virtuals/agent-contribution/contribute-to-voice-core.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
