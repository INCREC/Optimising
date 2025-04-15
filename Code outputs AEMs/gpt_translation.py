from openai import OpenAI
import sys
import os

# CHANGELOG
# 20250114 add extra prompts
# 20241210 add an extra argument for temperature
# 20241119 1st version (used for phase 1)


client = OpenAI(
  api_key=os.environ['OPENAIKEY']
)

# code updated to OpenAI's API 1.0 following https://github.com/openai/openai-python/discussions/742

model="gpt-4o-2024-08-06"
input_file = sys.argv[1] 
output_file = sys.argv[2]
target_language_code = sys.argv[3] #e.g. zh, nl, ca
mode = sys.argv[4] # values: sentences, all
temperature = float(sys.argv[5])
prompt_num = int(sys.argv[6])

#print(prompt_num)



def get_target_language(target_language_code):
    if target_language_code == "zh":
        target_language="Simplified Chinese"
    elif target_language_code == "nl":
        target_language="Dutch"
    elif target_language_code == "ca":
        target_language="Catalan"
    elif target_language_code == "es":
        target_language="Spanish"
    else:
        print("Target language code ", target_language_code, " not supported",  file=sys.stderr)
        sys.exit(1)
    print("Target language: ", target_language, file=sys.stderr)
    return target_language


def streamprompt(model, messages,temperature):

    completion = client.chat.completions.create(
        model=model,
        messages=messages,
        temperature=temperature
    )

    output = completion.choices[0].message
    print(output, file=sys.stderr)
    print(completion._request_id, file=sys.stderr)
    return output.content
    



# Translates the file sentence by sentence
def translate_file_sentences(input_file, output_file, model, target_language, temperature, prompt_num):
    with open(input_file, 'r', encoding='utf-8') as infile, open(output_file, 'w', encoding='utf-8') as outfile:
        for line in infile:
            if line.strip():
                match prompt_num:
                    case 1:
                        messages = [{"role": "user", "content": f"Translate into {target_language}: {line.strip()}"}]
                    case 2:
                        messages = [{"role": "user", "content": f"Translate the following text into {target_language} taking into consideration that this is from a science fiction story by Kurt Vonnegut: {line.strip()}"}]
                    case 3:
                        messages = [{"role": "user", "content": f"Translate the following text into {target_language} creatively: {line.strip()}"}]
                    case _:
                        print("Prompt number ", prompt_num, " not supported",  file=sys.stderr)
                        sys.exit(2)
                        
                translation = streamprompt(model, messages, temperature)
                if translation:
                    outfile.write(translation)
                    outfile.write('\n')
                else:
                    outfile.write('Translation failed for this line.\n')
                #break


# Translates the file all at once. Uses prompt 1
def translate_file_all(input_file, output_file, model, target_language, temperature, prompt_num):
    with open(input_file, 'r', encoding='utf-8') as infile, open(output_file, 'w', encoding='utf-8') as outfile:
        input_text = infile.read()

        match prompt_num:
            case 1:
                messages = [{"role": "user", "content": f"Translate the following text into {target_language}: {input_text}"}]
            case 2:
                messages = [{"role": "user", "content": f"Translate the following text into {target_language} taking into consideration that this is a science fiction story by Kurt Vonnegut: {input_text}"}]
            case 3:
                messages = [{"role": "user", "content": f"Translate the following text into {target_language} creatively: {input_text}"}]
            case _:
                print("Prompt number ", prompt_num, " not supported",  file=sys.stderr)
                sys.exit(2)

        #print(input_text)
        translation = streamprompt(model, messages, temperature)
        print(messages, file=sys.stderr)
        if translation:
            outfile.write(translation + '\n')
        else:
            outfile.write('Translation failed.\n')


target_language = get_target_language(target_language_code)
if mode == "sentences":
    translate_file_sentences(input_file, output_file, model, target_language, temperature, prompt_num)
elif mode == "all":
    translate_file_all(input_file, output_file, model, target_language, temperature, prompt_num)
else:
    print("Mode ", mode, " not supported", file=sys.stderr)

