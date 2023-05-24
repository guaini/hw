import requests
import os
import webbrowser
import time

debug = False

header = {
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
    "Accept-Encoding": "gzip, deflate",
    "Accept-Language": "zh-CN,zh;q=0,en;q=0.8,en-GB;q=0.7,en-US;q=0.6",
    "Cache-Control": "no-cache",
    "Connection": "keep-alive",
    "Host": "172.18.187.253",
    "Origin": "http://172.18.187.253",
    "Referer": "http://172.18.187.253/netdisk/uploadfile.aspx",
    "User-Agent": "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Mobile Safari/537.36 Edg/113.0.1774.50",
    "Upgrade-Insecure-Requests": "1"
}


def get_cookie():
    url = "http://172.18.187.253/netdisk/default.aspx"
    res = requests.get(url=url, params={"vm": "20web"})
    if res.status_code != 200:
        return None
    return res.cookies


def create_folder(dirname: str, cookies) -> bool:
    file = {
            "FileUpload1": "",
            "Content-Type": "text/html",
            "Content-Disposition": "form-data",
            "filename": ""
    }
    url = "http://172.18.187.253/netdisk/uploadfile.aspx"

    data = {
        "__VIEWSTATE": "/wEPDwUJLTI0MDUwNzIwD2QWAgIDDxYCHgdlbmN0eXBlBRNtdWx0aXBhcnQvZm9ybS1kYXRhZGQj7PZ29WrzVa1c9o3JVQfKU0UEnCKKtLlTNQoXkU1G9w==",
        "__VIEWSTATEGENERATOR": "9DF2453C",
        "__EVENTVALIDATION": "/wEdAASS3FO3GV7cA3k1b5Wnn4jB5vhDofrSSRcWtmHPtJVt4OZ/ps16smWapsh60U1606q6h/7n4xHPHfuPN0Utkq2mtqkbkjiDh+DaxaZJfcKufbSvCn1Mhlpx/6tPE6r1Hiw=",
        "btnCreateFolder": "建立文件夹",
        "txtFolder": dirname
    }

    res = requests.post(url=url, files=file, data=data, cookies=cookies)

    if res.status_code != 200:
        return False
    return True


def switch_folder(dirname: str, cookies) -> bool:
    dirname = dirname.replace(os.path.sep, '\\')

    url = "http://172.18.187.253/netdisk/ShowFolderContent.aspx"
    parameters = {
        "vm": "20web",
        "foldername": f"\\{dirname}",
        "rootindex": 0,
        "rootname": "webapps"
    }
    res = requests.get(url=url, headers=header, params=parameters, cookies=cookies)
    if res.status_code != 200:
        return False
    return True


def upload_file(filepath, content_type, cookies):
    file = {
            "FileUpload1": open(filepath, "rb"),
            # "Content-Type": content_type,
            "Content-Disposition": "form-data",
            "filename": filepath.split(os.path.sep)[-1]
    }

    data = {
        "__VIEWSTATE": "/wEPDwUJLTI0MDUwNzIwD2QWAgIDDxYCHgdlbmN0eXBlBRNtdWx0aXBhcnQvZm9ybS1kYXRhZGQj7PZ29WrzVa1c9o3JVQfKU0UEnCKKtLlTNQoXkU1G9w==",
        "__VIEWSTATEGENERATOR": "9DF2453C",
        "__EVENTVALIDATION": "/wEdAASS3FO3GV7cA3k1b5Wnn4jB5vhDofrSSRcWtmHPtJVt4OZ/ps16smWapsh60U1606q6h/7n4xHPHfuPN0Utkq2mtqkbkjiDh+DaxaZJfcKufbSvCn1Mhlpx/6tPE6r1Hiw=",
        "btnUpload": "上传",
        "txtFolder": ""
    }

    res = requests.post(
        url="http://172.18.187.253/netdisk/uploadfile.aspx",
        headers=header,
        files=file,
        cookies=cookies,
        data=data
    )

    if res.status_code != 200 or "上传成功" not in res.text:
        return False
    return True


def upload_dir(source, target, filter_file, cookies, check_time=0):
    if cookies is None:
        raise Exception("get cookies failed")

    for curr_path, dir_name, file_name in os.walk(source):
        relative_path = curr_path[len(source):]
        path_on_web = target + relative_path

        relative_path = relative_path.strip(os.path.sep)
        if relative_path in filter_file:
            print(f"ingore {curr_path}") if debug else None
            continue

        if not debug and not switch_folder(path_on_web, cookies):
            raise Exception(f"switch folder to {path_on_web} failed")

        print(f"switch to {path_on_web}") if debug else None

        for dn in dir_name:
            if os.path.join(relative_path, dn) in filter_file:
                print(f"\tdoes not create {dn} in {path_on_web}") if debug else None
                continue
            if os.stat(os.path.join(curr_path, dn)).st_ctime_ns <= check_time:
                print(f"\t{dn} has been created in {path_on_web}, skip") if debug else None
                continue
            if not debug and not create_folder(dn, cookies):
                raise Exception(f"create {dn} in {path_on_web} failed")
            print(f"\tcreate {dn} in {path_on_web}")

        for fn in file_name:
            file_path = os.path.join(curr_path, fn)
            if os.path.join(relative_path, fn) in filter_file:
                print(f"\tignore {file_path}") if debug else None
                continue
            if os.stat(file_path).st_mtime_ns <= check_time:
                print(f"\tdoes not update {file_path}, skip") if debug else None
                continue
            if not debug and not upload_file(file_path, "", cookies):
                raise Exception(f"upload {file_path} in {path_on_web} failed")
            print(f"\tupload {file_path} in {path_on_web}")


def get_check_time(check_file=".checkpoint.lock"):
    ret = 0
    if os.path.exists(check_file):
        ret = os.stat(check_file).st_mtime_ns
    with open(check_file, "w"):
        pass
    return ret


def main():
    dest = "image_sharing_test"
    src = "web"
    filter_file = [
        "WEB-INF\\lib\\commons-fileupload-1.2.1.jar",
        "WEB-INF\\lib\\commons-io-1.4.jar",
        "WEB-INF\\lib\\mysql-connector-java-5.1.39-bin.jar",
        "WEB-INF\\web.xml"
    ]
    cookies = get_cookie()

    check_time = get_check_time()

    upload_dir(src, dest, filter_file, cookies, check_time)

    print(f"last update: {check_time}") if debug else None

    print("done")

    time.sleep(1)
    webbrowser.open(url="http://172.18.187.253:8080/" + dest)


if __name__ == "__main__":
    main()
