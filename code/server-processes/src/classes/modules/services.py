import os
import datetime
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart


class Services:

    def log(self, message, log_dir="logs"):
        """
        Writes a message to a daily log file with a timestamp.

        Parameters:
        - message (str): The message to log.
        - log_dir (str): Directory where log files are stored.
        """
        # Ensure the log directory exists
        os.makedirs(log_dir, exist_ok=True)

        # Generate the log file name based on the current date
        date_str = datetime.datetime.now().strftime("%Y-%m-%d")
        log_filename = os.path.join(log_dir, f"{date_str}.log")

        # Generate the timestamp for the log entry
        time_str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        # Write the log entry to the file
        with open(log_filename, "a") as log_file:
            log_file.write(f"[{time_str}] {message}\n")

    def send_email(self, receiver, subject, body):
        """
        Send an email notification.
        
        Args:
            receiver: Email address of the recipient
            subject: Email subject line
            body: Email body text
        """
        sender = 'donotreply.mine.exchange@gmail.com'

        # Create the message
        msg = MIMEMultipart()
        msg['From'] = sender
        msg['To'] = receiver
        msg['Subject'] = subject

        msg.attach(MIMEText(body, 'plain'))

        # Login and send
        with smtplib.SMTP_SSL('smtp.gmail.com', 465) as server:
            server.login(sender, 'vcsb rjsd ivna ikpx')
            server.send_message(msg)