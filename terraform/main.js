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
        "https://gm0yznl72d.execute-api.ap-northeast-1.amazonaws.com/dev/tasks/" +
        user_name,
      dataType: "json",
    }).then(
      // 取得成功時
      function (json) {
        $(".tasks").empty();
        console.log(json);

        let tasks = json.services; //JSON.parse(json); //["tasks"];
        console.log(tasks[0]);

        for (let i = 0; i < tasks.length; i++) {
          console.log(tasks[i].task_name);
          task_name = tasks[i].task_name;
          task_id = tasks[i].task_id;
          $(".tasks").append(
            '<div class="card"><label><input type="checkbox" name="color" value="' +
              task_id +
              '"/>' +
              task_name +
              "</label></div>"
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
      url: "https://gm0yznl72d.execute-api.ap-northeast-1.amazonaws.com/dev/tasks/acna2676",
      data: JSON.stringify({ task: task }),
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

// ボタンを押したらタスクを削除する関数
$(function () {
  $("#delete-task").on("click", function (event) {
    let task_id = $("input[type='checkbox']:checked").val();
    console.log(task_id);

    $.ajax({
      type: "DELETE",
      url:
        "https://gm0yznl72d.execute-api.ap-northeast-1.amazonaws.com/dev/tasks/acna2676/" +
        task_id,
      data: JSON.stringify({ task: task }),
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
