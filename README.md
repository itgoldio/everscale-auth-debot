# Authorize From Debot

## Содержание
* [__Описание работы__](#description)
    * [Website backend](#backend)
    * [Debot](#debot)
    * [Callback server](#callback)
* [__Сборка контракта__](#how_to_build)
* [__Деплой контракта__](#how_to_deploy)

***

<h1 id="description">Описание работы:</h1>

<h2 id="backend">Website backend</h2>

Хранит:
1) debot addr
2) callback url - url, который обрабатывает POST запросы формата (id={}&signature={}&addr={}&pk={:064x})
3) debot.abi

Генерирует id и otp (one time password) и хранит в формате ключ -> значение, чтобы потом можно было по id найти otp.
Обращается к деботу по адресу, вызывая метод:

```
    function getInvokeMessage(string id, string otp, string callbackUrl) public pure returns(TvmCell message)
```

Получает закодированное msg.body и формирует uri по шаблону:

```
    https://uri.ton.surf/debot/<debot addr>?message=<msg body>&net=<network: mainnet or devnet>
```

<h2 id="debot">Debot</h2>

Получает wallet address и pubkey

```
    UserInfo.getAccount(tvm.functionId(getPublicKey));
    UserInfo.getPublicKey(tvm.functionId(setPk)); 
```

Хеширует строку, полученную конкатенацией otp (one time password) + userAddr

``` solidity
    Sdk.signHash(tvm.functionId(setSignature), handle, hash) 
```

Подписывает хеш, зараннее спрашивая юзера об этом.

``` 
    SigningBoxInput.get(tvm.functionId(setSigningBoxHandle), _signingBoxStr, pubkeys) 
```

Кодирует полученную подпись в base64

``` 
    Base64.encode(tvm.functionId(setEncode), signature) 
```

Отправляет POST запрос на callback url: req body - id={}&signature={}&addr={}&pk={:064x} (pk - pubkey)

```
    headers.push("Content-Type: application/x-www-form-urlencoded");
    string body = format("id={}&signature={}&addr={}&pk={:064x}", _id, base64, _userAddr, _userPubKey);
    Network.post(tvm.functionId(setResponse), _callbackUrl, headers, body);
```

Если ответ 200 - авторизация пройдена, иначе - провалена.


<h2 id="callback">Callback server</h2>

Получает POST запрос, по id находит otp

Используя js-SDK можно обработать запрос и получить результат того, что сообщение было подписано 
приватным ключом юзера и данным, находящимся внутри signature мы можем доверять

```javascript
   const { hash } = await this.crypto.sha256({
	data: Buffer.from(`${otp}${callbackUrl}${address}`, 'utf-8').toString(
		'base64'
	),
   });


   const { succeeded } = await this.client.crypto.nacl_sign_detached_verify({
      unsigned: Buffer.from(hash, 'hex').toString('base64'),
      signature: Buffer.from(signature.replace(/ /g, '+'), 'base64').toString('hex'),
   });
```

<h1 id="how_to_build">Сборка контракта</h1>

Изначально нужно провести настройку окружения. Редактируйте env.sh в корне репозитория:

```
#Укажите пути к tonos-cli, ton-solidity-compiler, tvm_linker и tml_linker_stdlib:
TON_CLI="/cli/target/release/tonos-cli"
TON_COMPILER="/solc/0.49.0/solc"
TVM_LINKER="/tvm-linker/tvm_linker"
TVM_LINKER_STDLIB="/solc/0.49.0/lib/stdlib_sol.tvm"
```
Выполняем build.all.sh в /contracts

После сборки нужно заменить файлы .abi.json, .decoded, .hash, .tvc в /versions/AuthDebot/1.1/

<h1 id="how_to_deploy">Деплой контракта</h1>

Изначально нужно провести настройку окружения. Процесс описан <a href="#how_to_build">тут</a>.
Для деплоя в:
* tonos-se:

```
#env.sh file
#Добавляем адрес SE сети
LOCALNET=""
```
Выполняем deploy.sh

* net.ton.dev или main.ton.dev сеть:
1) Выполняем genaddr.sh. 
2) На полученный адрес отправляем какое-то количество кристаллов (для активации аккаунта). 
3) Выполняем deploy.sh

Ключи лучше сгенерировать вручную в keys/debot
