$(function () {
  $("#image").on("change", function (event) {
    console.log(event);
    var reader = new FileReader();
    reader.onload = function (event) {
      $("#preview").attr("src", event.target.result);
    };
    reader.readAsDataURL(event.target.files[0]);
  });
});

// タスクを取得する関数
$(function () {
  $("#submit-task").on("click", function (event) {
    let user_name = "acna2676";

    $.ajax({
      type: "GET",
      url:
        "https://gm0yznl72d.execute-api.ap-northeast-1.amazonaws.com/dev/resource?user_name=" +
        user_name,
      dataType: "json",
    }).then(
      // 取得成功時
      function (json) {
        let tasks = JSON.parse(json)["tasks"];
        for (task in tasks) {
          $(".tasks").append(
            '<input type="checkbox" name="color" value="' + task + '" />' + task
          );
        }
      },
      function () {
        // エラー発生時
        alert("エラー時に表示されるテキスト");
      }
    );
  });
});

// ボタンを押したらタスクを登録する関数
$(function () {
  $("#submit-task").on("click", function (event) {
    let task = $("#task").val();

    $.ajax({
      type: "POST",
      url: "https://gm0yznl72d.execute-api.ap-northeast-1.amazonaws.com/dev/resource",
      data: { task: task },
      dataType: "json",
    }).then(
      // 取得成功時
      function (json) {},
      function () {
        // エラー発生時
        alert("エラー時に表示されるテキスト");
      }
    );
  });
});
