> For the complete documentation index, see [llms.txt](https://whitepaper.virtuals.io/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://whitepaper.virtuals.io/about-virtuals-1/the-protocol/ai-agent-co-contribution-and-provenance/modular-consensus-framework-for-ai-agent-governance/decentralized-ai-agent-contributions-and-nfts/voice-core-for-ai-agents.md).

# Voice Core for AI Agents

The Voice Core gives each VIRTUAL agent a distinct, personality-aligned voice. AI voice model training creates realistic, consistent speech for each agent and role.

### AI agent voice modules

**Speech-to-text (STT):** The STT module trains on diverse voice data. It accurately transcribes accents, dialects, and speech patterns across user scenarios.

**Text-to-speech (TTS):** The TTS module uses Variational Inference for Text-to-Speech (VITS) training. VITS produces high-quality, natural-sounding speech and supports voice synthesis customized to each AI agent’s personality.

Audio data preprocessing occurs before voice model training.

### Audio data preprocessing for voice models

1. **Audio format consistency:** WAV files at 22050 Hz in mono create consistent training inputs. Consistent input data helps machine learning voice models perform reliably.
2. **Sampling-rate normalization:** A 22050 Hz sampling rate captures human speech frequencies while keeping file sizes manageable. It captures frequencies up to 11025 Hz under the Nyquist theorem.
3. **Mono audio channels:** Converting stereo or multi-channel audio to mono gives the voice model one training channel and simplifies learning.

<details>

<summary>Sample Code</summary>

```python
import os
from pydub import AudioSegment

upload_dir = 'upload_dir'
output_dir = 'out'

# Ensure the output directory exists
os.makedirs(output_dir, exist_ok=True)

extensions = ['wav', 'mp3', 'ogg']

# Process all files in the upload directory
for filename in os.listdir(upload_dir):
    if any(filename.lower().endswith(ext) for ext in extensions):
        # Construct file paths
        file_path = os.path.join(upload_dir, filename)
        output_path = os.path.join(output_dir, os.path.splitext(filename)[0] + '.wav')

        # Load the audio file
        audio = AudioSegment.from_file(file_path)

        # Convert to WAV, 22050 Hz, mono
        audio = audio.set_frame_rate(22050).set_channels(1)

        # Export the processed audio
        audio.export(output_path, format='wav')

```

</details>

[<mark style="color:red;">Learn more about contributing to Voice Core.</mark>](/builders-hub/build-with-virtuals/agent-contribution/contribute-to-voice-core.md)


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/about-virtuals-1/the-protocol/ai-agent-co-contribution-and-provenance/modular-consensus-framework-for-ai-agent-governance/decentralized-ai-agent-contributions-and-nfts/voice-core-for-ai-agents.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
