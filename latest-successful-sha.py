# This is a sample Python script.

# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.
import sys
import requests


def last_success_hash(user: str, repo: str):
    url = "https://api.github.com/repos/{}/{}/actions/runs?per_page=1&status=success".format(user, repo)
    headers = {"accept": "application/vnd.github.v3+json"}
    resp = requests.get(url, headers=headers)
    if resp.status_code == 200:
        r_dict: dict = resp.json()
        head_sha = r_dict["workflow_runs"][0]["head_sha"]
        print(head_sha)
        return head_sha
    return "-1"


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    last_success_hash(sys.argv[1], sys.argv[2])

# See PyCharm help at https://www.jetbrains.com/help/pycharm/
