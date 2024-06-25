import asyncio
import os
from dotenv import load_dotenv
from helper_functions import print_ascii_art
from hume import HumeVoiceClient, MicrophoneInterface, VoiceSocket

# Global variables to store messages and count them
message_counter = 0
received_messages = []
socket_instance = None


def on_open():
    print_ascii_art("Say hello to EVI, Hume AI's Empathic Voice Interface!")


def on_message(message):
    global message_counter, received_messages
    message_counter += 1
    msg_type = message["type"]

    message_box = f"\n{'='*60}\n" f"Message {message_counter}\n" f"{'-'*60}\n"

    if msg_type in {"user_message", "assistant_message"}:
        role = message["message"]["role"]
        content = message["message"]["content"]
        message_box += f"role: {role}\n" f"content: {content}\n" f"type: {msg_type}\n"

        if "models" in message and "prosody" in message["models"]:
            scores = message["models"]["prosody"]["scores"]
            num = 3
            top_emotions = get_top_n_emotions(prosody_inferences=scores, number=num)

            message_box += f"{'-'*60}\nTop {num} Emotions:\n"
            for emotion, score in top_emotions:
                message_box += f"{emotion}: {score:.4f}\n"

        # Store the content in the received messages list
        received_messages.append(content)
    elif msg_type != "audio_output":
        for key, value in message.items():
            message_box += f"{key}: {value}\n"
        # Store the message in the received messages list
        received_messages.append(message)
    else:
        message_box += f"type: {msg_type}\n"

    message_box += f"{'='*60}\n"
    print(message_box)


def get_top_n_emotions(prosody_inferences, number):
    sorted_inferences = sorted(
        prosody_inferences.items(), key=lambda item: item[1], reverse=True
    )
    return sorted_inferences[:number]


def on_error(error):
    print(f"Error: {error}")


def on_close():
    print_ascii_art("Thank you for using EVI, Hume AI's Empathic Voice Interface!")


async def user_input_handler(socket: VoiceSocket):
    while True:
        user_input = await asyncio.to_thread(
            input, "Type a message to send or 'Q' to quit: "
        )
        if user_input.strip().upper() == "Q":
            print("Closing the connection...")
            await socket.close()
            break
        else:
            await socket.send_text_input(user_input)


# Main Function
async def hume_main() -> None:
    try:
        load_dotenv()

        HUME_API_KEY = os.getenv("HUME_API_KEY")
        HUME_SECRET_KEY = os.getenv("HUME_SECRET_KEY")
        HUME_CONFIG_ID = os.getenv("HUME_CONFIG_ID")

        client = HumeVoiceClient(HUME_API_KEY, HUME_SECRET_KEY)

        async with client.connect_with_handlers(
            config_id=HUME_CONFIG_ID,
            on_open=on_open,
            on_message=on_message,
            on_error=on_error,
            on_close=on_close,
            enable_audio=True,
        ) as socket:
            microphone_task = asyncio.create_task(MicrophoneInterface.start(socket))
            user_input_task = asyncio.create_task(user_input_handler(socket))

            await asyncio.gather(microphone_task, user_input_task)
    except asyncio.CancelledError:
        print("Asyncio task was cancelled.")
    except Exception as e:
        print(f"Exception occurred: {e}")


async def send_message_to_hume(message):
    global socket_instance
    if socket_instance:
        await socket_instance.send_text_input(message)
        print(f"Sent message: {message}")  # Debugging statement


async def close_hume_socket():
    global socket_instance
    if socket_instance:
        await socket_instance.close()
        socket_instance = None
        print("Closed WebSocket connection")  # Debugging statement
